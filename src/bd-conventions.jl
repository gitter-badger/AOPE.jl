# MIT License
# Copyright (c) 2019: Antonio Saragga Seabra

# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

             
##################
# Settlement Cycle
##################

"""
    settle(transactiondate::Date, settlementperiod, :HolydayCalendar)
    
Computes the settlement day using: 
- Transaction date 
- Settlement cycle period measured in business days (e.g. T+3, or more simply just 3)
- Business days calendars (e.g. :USNYSE, :TARGET,...)
"""
function liqd(transdate::Dates.Date, settcycle::Int, calendar)
    return advancebdays(convert(HolidayCalendar, calendar), transdate, settcycle)
end

function liqd(transdate::Dates.Date, settcycle::String, calendar)
    return advancebdays(convert(HolidayCalendar, calendar), transdate, parse(Int,settcycle[3]))
end



###################################################################
# Additional Days Count Convention
# Note: in DayCounts.jl 'const ActualActualISMA = ActualActualICMA'
###################################################################

"""
    ActualActualISMA()

**Actual/Actual ISMA** day count convention (e.g. London Stock Exchange, NASDAQ).

The year fraction is computed as:
```math
\\frac{\\text{# days between previous coupon and settlement date}}{\\text{# days in coupon period} \\times \\text{# coupon periods in a year}}
```

# Reference
- Information for private investors, January 2015, published by the London Stock Exchange Group
  https://www.londonstockexchange.com/traders-and-brokers/security-types/retail-bonds/accrued-interest-corp-supra.pdf
- Guide to Calculation Methods for the FTSE Fixed Income Indexes, v1.8
  https://www.ftse.com/products/downloads/FTSE_Fixed_Income_Index_Guide_to_Calculation_new.pdf
"""
struct ActualActualISMA <: DayCount end
function frac(startdate::Dates.Date, enddate::Dates.Date, nextcoupondate::Dates.Date, ::ActualActualISMA)
    daysbetweencoupons = Dates.value(nextcoupondate-startdate)
    if startdate > enddate || enddate > nextcoupondate
        error("start date > end date, or enddate > nextcoupondate")
    end
    return Dates.value(enddate-startdate)/(daysbetweencoupons*round(365/daysbetweencoupons))
end


###########################
# Business Days Conventions
###########################

abstract type BusinessDayConvention end
"""
    AllBD

Cashflows can land on weekends or holidays.
"""
struct AllBD <: BusinessDayConvention end
function utild(transdate::Dates.Date, ::Type{AllBD})
    return transdate
end
function utild(transdate::Dates.Date, ::Type{AllBD}, calendar)
    return transdate
end

# (A.1) if "Following" is specified, that date will be the first following day that is a Business Day;
# With following, cashflows are adjusted to land on the next good business day.
"""
    Following

Timings of cashflows that fall on a non-business day are adjusted to be on the the first **following** day that is a business day
"""
struct Following <: BusinessDayConvention end
function utild(transdate::Dates.Date,::Type{Following}, calendar)
    return tobday(convert(HolidayCalendar, calendar), transdate; forward = true)
end

# (A.2) if "Modified Following" or "Modified" is specified, that date will be the first following day that is a Business Day unless that day falls in the next calendar month, in which case that date will be the first preceding day that is a Business Day
# This is probably the most common business day convention used.  Cash flows that fall on weekends or holidays are assumed to be distributed on the following business day. However if the following business day is in a different month, the previous business day is adopted instead.
"""
    ModifiedFollowing

Timings of cashflows that fall on a non-business day are adjusted to be on the first **following** day that is a business day unless that day falls in the next calendar month, in which case that date will be the first **preceding** day that is a business day.
"""
struct ModifiedFollowing <: BusinessDayConvention end
function utild(transdate::Dates.Date,::Type{ModifiedFollowing}, calendar)
    maybe = tobday(convert(HolidayCalendar, calendar), transdate; forward = true)
    if month(maybe) == month(transdate)
        return maybe 
    else
        return tobday(convert(HolidayCalendar, calendar), transdate; forward = false)
    end
end


# (A.3) if "Preceding" is specified, that date will be the first preceding day that is a Business Day.
# Cash flows that fall on a non-business day are assumed to be distributed on the previous business day.
"""
    Preceding

Timings of cashflows that fall on a non-business day are adjusted to be on the first **preceding** day that is a business day.
"""
struct Preceding <: BusinessDayConvention end
function utild(transdate::Dates.Date,::Type{Preceding}, calendar)
    return tobday(convert(HolidayCalendar, calendar), transdate; forward = false)
end


# (5) Modified Preceding
# Cash flows that fall on a non-business day are assumed to be distributed on the previous business day. However if the previous business day is in a different month, the following business day is adopted instead.
struct ModifiedPreceding <: BusinessDayConvention end
function utild(transdate::Dates.Date,::Type{ModifiedPreceding}, calendar)
    maybe = tobday(convert(HolidayCalendar, calendar), transdate; forward = false)
    if month(maybe) == month(transdate)
        return maybe 
    else
        return tobday(convert(HolidayCalendar, calendar), transdate; forward = true)
    end
end


# End of Month - unadjusted
# All cash flows are assumed to be distributed on the final day of the month, even if it is a non-business day.
"""
    EndOfMonth

All cash flows are assumed to be distributed on the **final day of the month**, even if it is a non-business day.
"""
struct EndOfMonth <: BusinessDayConvention end
function utild(transdate::Dates.Date, ::Type{EndOfMonth})
    return Dates.lastdayofmonth(transdate)
end


# End of Month - Following
# All cash flows are assumed to be distributed on the final day of the month. If the final day of the month is a non-business day, the following business day is adopted.


# End of Month - Preceding
# All cash flows are assumed to be distributed on the final day of the month. If the final day of the month is a non-business day, the previous business day is adopted.


"""
    bdarray(A, convention, calendar)
    bdarray(A, convention, calendar, subsetcolumns)
        A: nxk Array 
        convention: BusinessDayConvention
        calender: HolydaysCalender
        subsetcolumns: number of the columns to be processed e.g. [1,4] - first and fouth columns processed, [1] - only first column processed. If omited, all columns will be processed.

Replace holidays and weekends in array A with business days according with a choosen business day convention and calander. The array A may have elements whose type is not Date (which will be skipped).    

"""
function bdarray(A, convention, calendar)
    nlines = size(A,1)
    ncolumns = size(A,2)    
    for j = 1:ncolumns
        for i = 1:nlines
            if typeof(A[i,j]) == Date
                A[i,j] = utild(A[i,j], convention, calendar) 
            end
        end
    end
    return A
end

function bdarray(A, convention, calendar, subsetcolumns)
    nlines = size(A,1)  
    for j in subsetcolumns
        for i = 1:nlines
            if typeof(A[i,j]) == Date
                A[i,j] = utild(A[i,j], convention, calendar) 
            end
        end
    end
    return A
end