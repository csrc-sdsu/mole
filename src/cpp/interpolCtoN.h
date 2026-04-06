/**
 * 
 */

#ifndef INTERPOLCTON_H
#define INTERPOLCTON_H

#include "utils.h"
#include <cassert>

class InterpolCtoN : public sp_mat
{
public:
    using sp_mat::operator=;

    /**
     * 
     */
    InterpolCtoN(u16 k, u32 m, const ivec& dc, const ivec& nc);
    
    /**
     * 
     */
    InterpolCtoN(u16 k, u32 m, u32 n, const ivec& dc, const ivec& nc);

    /**
     * 
     */
    InterpolCtoN(u16 k, u32 m, u32 n, u32 o, const ivec& dc, const ivec& nc);

private:

    /**
     * 
     */
    InterpolCtoN(u16 k, u32 m);

    /**
     * 
     */
    InterpolCtoN(u16 k, u32 m, bool dummy);
};

#endif //INTERPOLCTON_H