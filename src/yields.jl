
using Dates, BusinessDays, Roots, AOPE
# MIT License
# Copyright (c) 2019: Antonio Saragga Seabra

# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
"""
    yca(cleanprice,annualcoupons,redemptionvalue,startdate,enddate)

**Yield Corrente Ajustada** ou yield simples.

The simple yield is computed as:
```math
\\frac{\\text{annual total value of coupons}+(\\text{redemption value}-\\text{clean price})/L}{\\text{clean price}}
\\text{where}
L = \\frac{\\text{# days in the period excluding 29 Feb.}}{365}
```
"""
function yca(cleanprice, annualcoupons, redemptionvalue, startdate::Date, enddate::Date)
    L = (Dates.value(enddate - startdate) - ndays29feb(startdate,enddate))/365
    return (annualcoupons + (redemptionvalue - cleanprice)/L)/cleanprice
end


"""
    ytm(price,cf,m,dc)
        price: scalar 
        cf: K vector of cash flows
        m:  K vector of times for the cash flows
        dc: type of composition: Discrete/Continuous  

Computes the **Yield-to-Maturity** of a bond. The redemption date may be: maturity, call date, put date 

The ytr is computed as:
```math
ytr = y: \\text{price} = \\sum_{i=1}^k \\frac{cf_i}{(1+y)^{m_i}} 
ytr = y: \\text{price} = \\sum_{i=1}^k cf_i*\\exp{-y*m_i}} 
```
"""
function ytm(price,cf,m, dc)
    return Roots.find_zero(y->spreço(cf, m, y, dc)-price,0.01)
end


function ytmisda(P, g, k, h, n, f1, f2, C, v)
    return Roots.fzero(y->spreço(g, k, h, n, f1, f2, C, v, y)-P,0.01)
end


"""
zspread(price, cf, m, r, dc)

Computes the z-spread of a bond given benchmark interest rates and the dirty price (P) of the bond
    P:  liquidation price
    r:  scalar or K vector of benchmark interest rates
    cf: scalar or K vector of cash flows
    m:  K vector of times for the cash flows
    dc: Discrete/Continuous composition
returns
    scalar, the z-spread
"""
function zspread(P, cf, m, r, dc)
    return Roots.find_zero(z->spreço(cf, m, r, z, dc)-P,0.01)
end