module integrand_operands_m
  implicit none
contains

  pure function scalar(x) result(f)
    double precision, intent(in) :: x(:)
    double precision, allocatable :: f(:)
    f = (x**2)/2 ! <-- scalar function
  end function

  pure function vector(x) result(v)
    double precision, intent(in) :: x(:)
    double precision, allocatable :: v(:)
    v = x        ! <-- vector function
  end function

end module

program extended_gauss_divergence
  !! Print each term in the following residual formed from the extended Gauss-divergence
  !! theorem using one-dimensional (1D) 4th-(default) or 2nd-order mimetic discretizations:
  !! `residual = .SSS. (v .dot. .grad. f) * dV +.SSS. (f * .div. v) * dV - .SS. (f .x. (v .dot. dA))`
  !! where `.SSS.` and `.SS.` are the 1D equivalents of a volume integral over the whole
  !! domain and a surface integral over a domain boundary of unit area, respectively.
  use julienne_m, only : command_line_t
  use integrand_operands_m, only : scalar, vector
  use mole_m, only : scalar_1D_t, scalar_1D_initializer_i, vector_1D_t, vector_1D_initializer_i
  implicit none
  procedure(scalar_1D_initializer_i), pointer :: scalar_1D_initializer => scalar
  procedure(vector_1D_initializer_i), pointer :: vector_1D_initializer => vector

  type numerical_arguments_t
    !! Define default initializations that can be overridden with the command-line arguments
    !! detailed by the usage information below
    integer :: cells_=200, order_=4
    double precision :: x_min_=0D0, x_max_=1D0
  end type

  type text_flags_t
    logical div_, grad_, vf_
  end type

  type(command_line_t) command_line
  double precision SSS_v_dot_grad_f_dV, SSS_f_div_v_dV, SS_f_v_dot_dA

  if (command_line%argument_present([character(len=len("--help")) :: ("--help"), "-h"])) then
    stop                              new_line('') // new_line('') &
      // 'Usage:'                                  // new_line('') &
      // '  fpm run \'                             // new_line('') &
      // '  --example extended-gauss-divergence \' // new_line('') &
      // '  --compiler flang-new \'                // new_line('') &
      // '  --flag "-O3" \'                        // new_line('') &
      // '  -- [--help|-h] | [[--cells <integer>] [--order <integer>] [--xmin <double precision>] [--xmax <double precision>] [--div|d] [--grad|g] [--vf|f]]' &
      //                              new_line('') // new_line('') &
      // 'where pipes (|) separate square-bracketed optional arguments and angular brackets indicate user input values.' // new_line('')
  end if

  call execute_command_line("grep '<-- scalar' example/extended-gauss-divergence.F90 | grep -v execute_command", wait=.true.)
  call execute_command_line("grep '<-- vector' example/extended-gauss-divergence.F90 | grep -v execute_command", wait=.true.)

#ifdef __GFORTRAN__
  command_line_arguments: &
  block
    type(numerical_arguments_t) args
    args  = get_numerical_arguments()
#else
  command_line_arguments: &
  associate(args => get_numerical_arguments())
#endif
    text_flags: &
    associate(flags => text_flags_t( &
       div_  = command_line%argument_present( [ character(len=len("--div" )) :: "--div" , "-d" ] ) &
      ,grad_ = command_line%argument_present( [ character(len=len("--grad")) :: "--grad", "-g" ] ) &
      ,vf_   = command_line%argument_present( [ character(len=len("--vf"  )) :: "--vf"  , "-f" ] ) &
    ))
      print_all: &
      associate(all_terms => merge(.true., .false., all([flags%div_, flags%grad_, flags%vf_]) .or. .not. any([flags%div_, flags%grad_, flags%vf_])))
        integrand_factors: &
        associate( &
           f => scalar_1D_t(scalar_1D_initializer, args%order_, args%cells_, args%x_min_, args%x_max_) &
          ,v => vector_1D_t(vector_1D_initializer, args%order_, args%cells_, args%x_min_, args%x_max_) &
        )
          differential_volume: &
          associate(dV => f%dV())

            if (flags%grad_ .or. all_terms) then
              SSS_v_dot_grad_f_dV = .SSS. (v .dot. .grad. f) * dV
              print '(a,g0)', ".SSS. (v .dot. .grad. f) * dV = ", SSS_v_dot_grad_f_dV
            end if

            if (flags%div_ .or. all_terms) then
              SSS_f_div_v_dV      = .SSS. (f * .div. v) * dV
              print '(a,g0)', ".SSS. (     f * .div. v) * dV = ", SSS_f_div_v_dV
            end if

          end associate differential_volume

          differential_area: &
          associate(dA => v%dA())
            if (flags%vf_ .or. all_terms) then
              SS_f_v_dot_dA       =  .SS. (f .x. (v .dot. dA))
              print '(a,g0)', "     -.SS. (f .x. (v .dot. dA)) = ", -SS_f_v_dot_dA
            end if

            if (all_terms) then
              print '(a)'   , "----------------------------------------------------"
              print '(26x,a,g0,a)',"sum = ", SSS_v_dot_grad_f_dV  +  SSS_f_div_v_dV - SS_f_v_dot_dA, " (residual)"
            end if

          end associate differential_area
        end associate integrand_factors
      end associate print_all
    end associate text_flags
#ifndef __GFORTRAN__
  end associate command_line_arguments
#else
  end block command_line_arguments
#endif

contains

  function get_numerical_arguments() result(numerical_arguments)
    type(numerical_arguments_t) numerical_arguments

#ifdef __GFORTRAN__
    character(len=:), allocatable :: cells_string, order_string, x_min_string, x_max_string
    cells_string = command_line%flag_value("--cells")
    order_string = command_line%flag_value("--order")
    x_min_string = command_line%flag_value("--x_min")
    x_max_string = command_line%flag_value("--x_max")
#else
    associate( &
       cells_string => command_line%flag_value("--cells") &
      ,order_string => command_line%flag_value("--order") &
      ,x_min_string => command_line%flag_value("--x_min") &
      ,x_max_string => command_line%flag_value("--x_max") &
    )
#endif
      if (len(cells_string)/=0) read(cells_string,*) numerical_arguments%cells_
      if (len(order_string)/=0) read(order_string,*) numerical_arguments%order_
      if (len(x_min_string)/=0) read(x_min_string,*) numerical_arguments%x_min_
      if (len(x_max_string)/=0) read(x_max_string,*) numerical_arguments%x_max_
#ifndef __GFORTRAN__
    end associate
#endif

  end function

end program
