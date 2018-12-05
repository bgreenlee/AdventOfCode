(ns spiral-memory-2.core
  (:gen-class)
  (:require [clojure.math.numeric-tower :as math]))

(defn spiral-memory [n]
 0)

(defn -main
  [& args]
  (def n (read-string (first *command-line-args*)))
  (println (spiral-memory n)))
