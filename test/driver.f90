program test_suite_driver
  use julienne_m, only : test_fixture_t, test_harness_t
  use gradient_operator_1D_test_m, only : gradient_operator_1D_test_t
  use divergence_operator_1D_test_m, only : divergence_operator_1D_test_t
  implicit none

  associate(test_harness => test_harness_t([ &
     test_fixture_t(gradient_operator_1D_test_t()) &
    ,test_fixture_t(divergence_operator_1D_test_t()) &
  ]))
    call test_harness%report_results
  end associate
end program test_suite_driver
