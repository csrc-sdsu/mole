#-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
#
#Project created by QtCreator 2016 - 02 - 10T18 : 54 : 30
#
#-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -

QT -= core gui

    TARGET = mole TEMPLATE = lib CONFIG = staticlib

        ARMA = / home / johnny / armadillo - 7.950.1

               INCLUDEPATH = $$ARMA / include LIBS = $$ARMA

                                 QMAKE_CXXFLAGS_RELEASE -=
    -O2 QMAKE_CXXFLAGS_RELEASE += -O3

                                      HEADERS +=
    divergence.h gradient.h laplacian.h mole.h operators.h interpol.h utils.h

        SOURCES +=
    divergence.cpp gradient.cpp laplacian.cpp interpol.cpp utils.cpp

        unix {
  target.path = / usr / lib INSTALLS += target
}
