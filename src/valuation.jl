# MIT License
# Copyright (c) 2019: Antonio Saragga Seabra

# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

"""
    nfcaixa(startdate::Date, maturity::Date, frequency)
        startdate: date scalar 
        maturity: date scalar
        frequency: 0 (zero-coupn), 1 (annual), 2 , 3, 4, 6, 12 (monthly).

Computes the **number of cash-flows** of a bond between dates [startdate, maturity], given the annual frequency - freq.
"""
function nfcaixa(startdate::Date, enddate::Date, frequency::Int64)
    if freq == 0
        return 1
    elseif rem(12,frequency) != 0 
        return println("\x1b[94m*** ERROR: freq = $freq. Note that freq must be: 0 (zero-coupon), 1 (annual), 2, 3, 4, 6, 12 (monthly).\x1b[37m") 
    else
        i = 0
        date = startdate
        while date <= enddate
            i = i + 1
            date = date + Dates.Month(12/frequency)
        end
        return i
    end
end

"""
Bond Cashflows - **Bullet Bonds**

function cf(startdate::Date, maturity::Date, couponrate, frequency, [principal = 100])
    startdate: date scalar 
    maturity: date scalar
    frequency: 0 (zero-coupn), 1 (annual), 2 , 3, 4, 6, 12 (monthly).

    kx2 array - Calculates the timing and value (interest + principal) of all cash flows. The entire principal value is paid all at once on the maturity date. Principal is by default set equal to 100. Zero-coupons have 'freq' equal to 0.
"""
function fcaixa(startdate::Date, enddate::Date, couponrate, frequency::Int64; principal = 100)
    if frequency == 0
        return [enddate principal]
    elseif rem(12,frequency) != 0 
        return println("\x1b[94m*** ERROR: freq = $freq. Note that freq must be: 0 (zero-coupon), 1 (annual), 2, 3, 4, 6, 12 (monthly).\x1b[37m") 
    else
        cfvalue = (1+couponrate/frequency) * principal
        cashflows = [enddate cfvalue]
        cfdate = enddate - Dates.Month(12/frequency)
        while startdate < cfdate
            cashflows = [cashflows; [cfdate couponrate/frequency*principal]]
            cfdate = cfdate - Dates.Month(12/frequency)
        end
        return cashflows
    end    
end

"""
Bond Cashflows - **Bonds with Amortization of Principal**

function fcaixa(startdate::Date, maturity::Date, couponrate, frequency, amortiz, [principal = 100])
    startdate: date scalar 
    maturity: date scalar
    frequency: 0 (zero-coupn), 1 (annual), 2 , 3, 4, 6, 12 (monthly).
    amortiz: scalar

    kx2 Array{Date,Float64} - Calculates the timing and value (interest+principal) of all cash flows. The entire principal value is paid all at once on the maturity date. There is a linear amortization schedulle.
"""
function fcaixa(startdate::Date, enddate::Date, couponrate, frequency::Int64, amortiz; principal = 100)
    if rem(principal,amortiz) != 0
        println("\x1b[94m*** ERROR: Principal is not an integer multiple of the amortization value!\x1b[37m")
    end
    i = 1
    cfvalue = (1+couponrate/frequency) * amortiz
    cashflows = [enddate cfvalue]
    cfdate = enddate - Dates.Month(12/frequency)
    while startdate < cfdate 
        i = i + 1
        cashflows = [cashflows; [cfdate (1 + couponrate/frequency * i ) * amortiz]]
        cfdate = cfdate - Dates.Month(12/frequency)
    end
    return cashflows
end    

"""
spreço(cf, r, m, dc)

Computes the clean price of a bond
    r:  scalar or K vector of interest rates
    cf: scalar or K vector of cash flows
    m: K vector of times for the cash flows
    dc: Discrete/Continuous composition
"""
function spreço
end
function spreço(cf,m,r, ::Type{Discrete})  #cf is a vector of all cash flows at times m
    dcf = cf./((r.+1).^m)                     #cf1/(1+r1)^m1 + cf2/(1+r2)^m2 + ...
    return sum(dcf)                   
end

function spreço(cf,m,r, ::Type{Continuous})  #cf is a vector of all cash flows at times m
    dcf = cf.* exp.(-r.*m)                      #cf1*exp(-r1*m1) + cf2*exp(-r2*m2) + ...
    return sum(dcf)                   
end

"""
spreço(g, k, h, n, f1, f2, C, v, y)

Computes the dirty price (clean price plus accrued interest) of the bond using the ISMA formula
Brown, P. J. (1998): Bond Markets, Structures and Yields Calculations. ISMA Publication.
"""
function spreço(g, k, h, n, f1, f2, C, v, y)
    v = 1/(1+y/h)
    return v^f1 * (k + g/h * (v * (1-v^(n-1)) / (1-v)) + (C + g/h * f_2)*v^(n+f2-1))
end


"""
spreço(cf, m, r, z, dc)

Computes the dirty price (clean price plus accrued interest) of the bond using information about the z-spread and benchmark interest rates
    r:  scalar or K vector of benchmark interest rates
    cf: scalar or K vector of cash flows
    m:  K vector of times for the cash flows
    z:  scalar, the z-spread  
    dc: Discrete/Continuous composition
"""
function spreço(cf,m,r, z, ::Type{Discrete})  #cf is a vector of all cash flows at times m
    dcf = cf./((r.+1).^m .*(z+1).^m)                     #cf1/(1+r1)^m1 + cf2/(1+r2)^m2 + ...
    return sum(dcf)                   
end
function spreço(cf,m,r, z, ::Type{Continuous})  #cf is a vector of all cash flows at times m
    dcf = cf.* exp.(-(r.+z).*m)                      #cf1*exp(-r1*m1) + cf2*exp(-r2*m2) + ...
    return sum(dcf)                   
end
