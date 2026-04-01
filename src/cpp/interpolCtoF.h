/**
 * 
 */

#ifndef INTERPOLCTOF_H
#define INTERPOLCTOF_H

#include "utils.h"
#include <cassert>

/**
 * 
 */
class InterpolCtoF : public sp_mat {

public:
    using sp_mat::operator=;

    /**
     * 
     */
    InterpolCtoF(u16 k, u32 m, const ivec& dc, const ivec& nc);

    /**
     * 
     */
    InterpolCtoF(u16 k, u32 m, u32 n, const ivec& dc, const ivec& nc);

    /**
     * 
     */
    InterpolCtoF(u16 k, u32 m, u32 n, u32 o, const ivec& dc, const ivec& nc);

private:

    /**
     * 
     */
    InterpolCtoF(u16 k, u32 m);

    /**
     * 
     */
    InterpolCtoF(u16 k, u32 m, bool dummy);
};

#endif //INTERPOLCTOF_H