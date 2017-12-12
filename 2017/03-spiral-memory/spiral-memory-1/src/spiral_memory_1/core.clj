(ns spiral-memory-1.core
  (:gen-class)
  (:require [clojure.math.numeric-tower :as math]))

(defn spiral-memory-dist [n]
 ;; the square root of the number determines which layer of the spiral it is in
 (def root (int (math/ceil (math/sqrt n))))
 ;; length of one side of this part of the spiral
 (def len (+ root (- 1 (mod root 2))))
 ;; the offset from the corner of this layer of the spiral
 ;; the if avoids a divide-by-zero for n=1
 (def offset (if (> len 1) (mod (- (* len len) n) (- len 1)) 0))
 ;; adjust for offset depending on which side of center they are
 (def dist (if (> offset (/ len 2)) offset (- (- len 1) offset)))

 dist)

(defn -main
  [& args]
  (def n (read-string (first *command-line-args*)))
  (println (spiral-memory-dist n)))
