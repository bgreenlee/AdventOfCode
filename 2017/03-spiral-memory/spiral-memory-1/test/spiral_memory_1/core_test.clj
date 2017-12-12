(ns spiral-memory-1.core-test
  (:require [clojure.test :refer :all]
            [spiral-memory-1.core :refer :all]))

(deftest a-test
  (testing "spiral-memory-dist"
    (is (= (spiral-memory-dist 1) 0))
    (is (= (spiral-memory-dist 12) 3))
    (is (= (spiral-memory-dist 23) 2))
    (is (= (spiral-memory-dist 1024) 31))
    (is (= (spiral-memory-dist 325489) 552))
  )
)
