module TestTesting

import SplittablesTesting

SplittablesTesting.test_ordered(Any[1:10, 1:11])
SplittablesTesting.test_unordered(Any[Set(1:10), Set(1:11)])

end  # module
