(ns spiral-memory-2.core-test
  (:require [clojure.test :refer :all]
            [spiral-memory-2.core :refer :all]))

(deftest a-test
  (testing "spiral-memory"
    (is (= (spiral-memory 1) 1))
    (is (= (spiral-memory 2) 1))
    (is (= (spiral-memory 3) 2))
    (is (= (spiral-memory 4) 4))
    (is (= (spiral-memory 5) 5))
    (is (= (spiral-memory 6) 10))
    (is (= (spiral-memory 7) 11))
    (is (= (spiral-memory 8) 23))
    (is (= (spiral-memory 9) 25))
    (is (= (spiral-memory 10) 26))
    (is (= (spiral-memory 11) 54))
    (is (= (spiral-memory 12) 57))
    (is (= (spiral-memory 13) 59))
    (is (= (spiral-memory 14) 122))
    (is (= (spiral-memory 15) 133))
))
