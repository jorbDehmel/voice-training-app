# From https://codewithandrea.com/articles/flutter-test-coverage/
.PHONY:	unittest
unittest:
	flutter test --coverage
	genhtml coverage/lcov.info -o coverage/html > coverage/summary.txt
