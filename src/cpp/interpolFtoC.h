/**
 * 
 */

#ifndef INTERPOLFTOC_H
#define INTERPOLFTOC_H

#include "utils.h"
#include <cassert>

class InterpolFtoC : public sp_mat {

public:
    using sp_mat::operator=;

    /**
     * 
     */
    InterpolFtoC(u16 k, u32 m, const ivec& dc, const ivec& nc);

    /**
     * 
     */
    InterpolFtoC(u16 k, u32 m, u32 n, const ivec& dc, const ivec& nc);

    /**
     * 
     */
    InterpolFtoC(u16 k, u32 m, u32 n, u32 o, const ivec& dc, const ivec& nc);

private:
    
    /**
     * 
     */
    InterpolFtoC(u16 k, u32 m);

    /**
     * 
     */
    InterpolFtoC(u16 k, u32 m, bool dummy);
};

#endif //INTERPOLFTOC_H