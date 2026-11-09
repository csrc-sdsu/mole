run_octave_tests:
	for test_name in \
		testGradient \
		testDivergence \
		testLaplacian \
		testAddScalarBC \
		testBCConsistency \
		testDivPolynomial \
		testEnergy \
		testGI13Curv \
		testGradPolynomial \
		testLapPolynomial \
		testPoissonAccuracy \
		testTTMGrids; do \
		octave --quiet --eval "addpath(pwd()); test('$$test_name')" || exit 1; \
	done

