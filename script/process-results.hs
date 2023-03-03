import Data.List
import System.Directory
import System.Environment
import System.FilePath
import Text.Printf
import Text.Regex.TDFA

resultFileNameRegex :: String
resultFileNameRegex = "champsim-([a-z]+)\\.(.*)-([0-9]+)B"

ipcRegex :: String
ipcRegex = "CPU 0 cumulative IPC: ([0-9]+.?[0-9]*)"

readIpc :: FilePath -> IO (Maybe Double)
readIpc file = do
  content <- readFile file
  case content =~ ipcRegex :: (String, String, String, [String]) of
    (_, _, _, [ipc]) -> return $ Just $ read ipc
    _ -> return Nothing

parseResultFileName :: FilePath -> (String, String, Int)
parseResultFileName name = (replacement, benchmark, read simpoint)
 where
  (_, _, _, [replacement, benchmark, simpoint]) =
    name =~ resultFileNameRegex ::
      (String, String, String, [String])

readResults :: FilePath -> IO [(String, String, Int, Maybe Double)]
readResults dir = do
  files <- filter (=~ resultFileNameRegex) <$> listDirectory dir
  ipcs <- mapM (readIpc . (dir </>)) files
  return $
    zipWith
      (\(replacement, benchmark, simpoint) ipc -> (replacement, benchmark, simpoint, ipc))
      (map parseResultFileName files)
      ipcs

readWeights :: FilePath -> IO [(String, [(Int, Double)])]
readWeights dir = do
  benchmarks <- listDirectory dir
  simpoints <- mapM (\benchmark -> readFile $ dir </> benchmark </> "simpoints.out") benchmarks
  weights <- mapM (\benchmark -> readFile $ dir </> benchmark </> "weights.out") benchmarks
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
  [ ( replacement
    , benchmark
    , sum
        <$> mapM
          ( \(simpoint, ipc) ->
              let weight = lookup simpoint simpoints
               in (*) <$> weight <*> ipc
          )
          [ (simpoint, ipc)
          | (replacement', benchmark', simpoint, ipc) <- results
          , replacement == replacement' && benchmark == benchmark'
          ]
    )
  | replacement <- nub $ map (\(repl, _, _, _) -> repl) results
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
    (unwords . sort . nub $ map (\(repl, _, _) -> repl) sortedResults)
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
  putStr $ toWSC $ weighResults results weights
