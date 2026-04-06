/**
 * 
 */

#ifndef INTERPOLNTOC_H
#define INTERPOLNTOC_H

#include "utils.h"
#include <cassert>

class InterpolNtoC : public sp_mat
{
public:
    using sp_mat::operator=;

    /**
     * 
     */
    InterpolNtoC(u16 k, u32 m, const ivec& dc, const ivec& nc);

    /**
     * 
     */
    InterpolNtoC(u16 k, u32 m, u32 n, const ivec& dc, const ivec& nc);

    /**
     * 
     */
    InterpolNtoC(u16 k, u32 m, u32 n, u32 o, const ivec& dc, const ivec& nc);

private:
    
    /**
     * 
     */
    InterpolNtoC(u16 k, u32 m);

    /**
     * 
     */
    InterpolNtoC(u16 k, u32 m, bool dummy);
};

#endif //INTERPOLNTOC_H