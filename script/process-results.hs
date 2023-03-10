import Data.List
import qualified Data.Vector as V
import Statistics.Sample
import System.Directory
import System.Environment
import System.FilePath
import System.IO
import Text.Printf
import Text.Regex.TDFA

resultFileNameRegex :: String
resultFileNameRegex = "^champsim-([^.]+)\\.(.*)-([0-9]+)B$"

benchmarkDirRegex :: String
benchmarkDirRegex = "^[0-9]+\\.[^.]+$"

ipcRegex :: String
ipcRegex = "CPU 0 cumulative IPC: ([0-9]+.?[0-9]*)"

readIpc :: FilePath -> IO (Maybe Double)
readIpc file = do
  content <- readFile' file
  case content =~ ipcRegex :: (String, String, String, [String]) of
    (_, _, _, [ipc]) -> return $ Just $ read ipc
    _ -> return Nothing

parseResultFileName :: FilePath -> (String, String, Int)
parseResultFileName name = (config, benchmark, read simpoint)
 where
  (_, _, _, [config, benchmark, simpoint]) =
    name =~ resultFileNameRegex ::
      (String, String, String, [String])

readResults :: FilePath -> IO [(String, String, Int, Maybe Double)]
readResults dir = do
  files <- filter (=~ resultFileNameRegex) <$> listDirectory dir
  ipcs <- mapM (readIpc . (dir </>)) files
  return $
    zipWith
      (\(config, benchmark, simpoint) ipc -> (config, benchmark, simpoint, ipc))
      (map parseResultFileName files)
      ipcs

readWeights :: FilePath -> IO [(String, [(Int, Double)])]
readWeights dir = do
  benchmarks <- filter (=~ benchmarkDirRegex) <$> listDirectory dir
  simpoints <- mapM (\benchmark -> readFile' $ dir </> benchmark </> "simpoints.out") benchmarks
  weights <- mapM (\benchmark -> readFile' $ dir </> benchmark </> "weights.out") benchmarks
  return $
    zipWith3
      ( \benchmark simpoint weight ->
          (benchmark, zip (map read $ lines simpoint) (map read $ lines weight))
      )
      benchmarks
      simpoints
      weights

weighResults ::
  [(String, String, Int, Maybe Double)] ->
  [(String, [(Int, Double)])] ->
  [(String, String, Maybe Double)]
weighResults results weights =
  [ ( config
    , benchmark
    , sum
        <$> mapM
          ( \(simpoint, ipc) ->
              let weight = lookup simpoint simpoints
               in (*) <$> weight <*> ipc
          )
          [ (simpoint, ipc)
          | (config', benchmark', simpoint, ipc) <- results
          , config == config' && benchmark == benchmark'
          ]
    )
  | config <- nub $ map (\(c, _, _, _) -> c) results
  , (benchmark, simpoints) <- weights
  ]

benchmarkWSC :: String -> [(String, Maybe Double)] -> String
benchmarkWSC benchmark results =
  printf
    "%s %s\n"
    benchmark
    (unwords ipcs)
 where
  sortedResults = sortBy (\x y -> compare (fst x) (fst y)) results
  ipcString Nothing = "NaN"
  ipcString (Just ipc) = show ipc
  ipcs = map (ipcString . snd) sortedResults

toWSC :: [(String, String, Maybe Double)] -> String
toWSC results =
  printf
    "benchmark %s\n\
    \%s"
    (unwords . sort . nub $ map (\(c, _, _) -> c) sortedResults)
    ( concat
        [ benchmarkWSC benchmark $
          map (\(repl, _, ipc) -> (repl, ipc)) $
            filter (\(_, benchmark', _) -> benchmark == benchmark') sortedResults
        | benchmark <- nub $ map (\(_, benchmark, _) -> benchmark) sortedResults
        ]
    )
 where
  sortedResults = sortBy (\(_, b1, _) (_, b2, _) -> compare b1 b2) results

main :: IO ()
main = do
  [weightDir, resultDir] <- getArgs
  results <- readResults resultDir
  weights <- readWeights weightDir
  let weightedResults = weighResults results weights
      means =
        [ let configResults = [ipc | (c, _, ipc) <- weightedResults, c == config]
           in (config, "geoMean", geometricMean . V.fromList <$> sequence configResults)
        | config <- nub $ map (\(c, _, _) -> c) weightedResults
        ]
   in putStr $ toWSC $ weightedResults ++ means
