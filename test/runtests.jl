using AOPE, BusinessDays, Dates
using Test

@testset "settle" begin
    @test liqd(Date(2010, 8, 13), "T+3", :UKSettlement) == Date(2010, 8, 18)
    @test liqd(Date(2010, 8, 13),     3, :UKSettlement) == Date(2010, 8, 18)
    @test liqd(Date(2010, 8, 13),     0, :UKSettlement) == Date(2010, 8, 13)
end

# based on tests from OpenGamma Strata
# https://github.com/OpenGamma/Strata/blob/efaa0be0d08dc61c23692e7b86df101ea0fb7223/modules/basics/src/test/java/com/opengamma/strata/basics/date/DayCountTest.java
@testset "Actual365Fixed" begin
    dc = Actual365Fixed()
    @test frac(Date(2011,12,28), Date(2012, 2,28), dc) == (4 + 58) / 365
    @test frac(Date(2011,12,28), Date(2012, 2,29), dc) == (4 + 59) / 365
    @test frac(Date(2011,12,28), Date(2012, 3, 1), dc) == (4 + 60) / 365
    @test frac(Date(2011,12,28), Date(2016, 2,28), dc) == (4 + 366 + 365 + 365 + 365 + 58) / 365
    @test frac(Date(2011,12,28), Date(2016, 2,29), dc) == (4 + 366 + 365 + 365 + 365 + 59) / 365
    @test frac(Date(2011,12,28), Date(2016, 3, 1), dc) == (4 + 366 + 365 + 365 + 365 + 60) / 365
    @test frac(Date(2012, 2,28), Date(2012, 3,28), dc) == 29 / 365
    @test frac(Date(2012, 2,29), Date(2012, 3,28), dc) == 28 / 365
    @test frac(Date(2012, 3, 1), Date(2012, 3,28), dc) == 27 / 365

    # zeros
    @test frac(Date(2011,12,28), Date(2011,12,28), dc) == 0
    @test frac(Date(2011,12,31), Date(2011,12,31), dc) == 0
    @test frac(Date(2012, 2,28), Date(2012, 2,28), dc) == 0
    @test frac(Date(2012, 2,29), Date(2012, 2,29), dc) == 0
end

@testset "Actual360" begin
    dc = Actual360()
    @test frac(Date(2011,12,28), Date(2012, 2,28), dc) == (4 + 58) / 360
    @test frac(Date(2011,12,28), Date(2012, 2,29), dc) == (4 + 59) / 360
    @test frac(Date(2011,12,28), Date(2012, 3, 1), dc) == (4 + 60) / 360
    @test frac(Date(2011,12,28), Date(2016, 2,28), dc) == (4 + 366 + 365 + 365 + 365 + 58) / 360
    @test frac(Date(2011,12,28), Date(2016, 2,29), dc) == (4 + 366 + 365 + 365 + 365 + 59) / 360
    @test frac(Date(2011,12,28), Date(2016, 3, 1), dc) == (4 + 366 + 365 + 365 + 365 + 60) / 360
    @test frac(Date(2012, 2,28), Date(2012, 3,28), dc) == 29 / 360
    @test frac(Date(2012, 2,29), Date(2012, 3,28), dc) == 28 / 360
    @test frac(Date(2012, 3, 1), Date(2012, 3,28), dc) == 27 / 360

    # zeros
    @test frac(Date(2011,12,28), Date(2011,12,28), dc) == 0
    @test frac(Date(2011,12,31), Date(2011,12,31), dc) == 0
    @test frac(Date(2012, 2,28), Date(2012, 2,28), dc) == 0
    @test frac(Date(2012, 2,29), Date(2012, 2,29), dc) == 0
end

@testset "ActualActualISDA" begin
    dc = ActualActualISDA()
    @test frac(Date(2011,12,28), Date(2012, 2,28), dc) == 4 / 365 + 58 / 366
    @test frac(Date(2011,12,28), Date(2012, 2,29), dc) == 4 / 365 + 59 / 366
    @test frac(Date(2011,12,28), Date(2012, 3, 1), dc) == 4 / 365 + 60 / 366
    @test frac(Date(2011,12,28), Date(2016, 2,28), dc) == 4 / 365 + 58 / 366 + 4
    @test frac(Date(2011,12,28), Date(2016, 2,29), dc) == 4 / 365 + 59 / 366 + 4
    @test frac(Date(2011,12,28), Date(2016, 3, 1), dc) == 4 / 365 + 60 / 366 + 4
    @test frac(Date(2012, 2,28), Date(2012, 3,28), dc) == 29 / 366
    @test frac(Date(2012, 2,29), Date(2012, 3,28), dc) == 28 / 366
    @test frac(Date(2012, 3, 1), Date(2012, 3,28), dc) == 27 / 366

    # zeros
    @test frac(Date(2011,12,28), Date(2011,12,28), dc) == 0
    @test frac(Date(2011,12,31), Date(2011,12,31), dc) == 0
    @test frac(Date(2012, 2,28), Date(2012, 2,28), dc) == 0
    @test frac(Date(2012, 2,29), Date(2012, 2,29), dc) == 0
end

@testset "Thirty360" begin
    dc = Thirty360()
    # usual rule: ((d2-d1) + (m2-m1)*30 + (y2-y1)*360)/360
    @test frac(Date(2011,12,28), Date(2012, 2,28), dc) == ((28-28) + (2-12)*30 + (2012-2011)*360)/360
    @test frac(Date(2011,12,28), Date(2012, 2,29), dc) == ((29-28) + (2-12)*30 + (2012-2011)*360)/360
    @test frac(Date(2011,12,28), Date(2012, 3, 1), dc) == ((1-28) + (3-12)*30 + (2012-2011)*360)/360
    @test frac(Date(2011,12,28), Date(2016, 2,28), dc) == ((28-28) + (2-12)*30 + (2016-2011)*360)/360
    @test frac(Date(2011,12,28), Date(2016, 2,29), dc) == ((29-28) + (2-12)*30 + (2016-2011)*360)/360
    @test frac(Date(2011,12,28), Date(2016, 3, 1), dc) == ((1-28) + (3-12)*30 + (2016-2011)*360)/360
    @test frac(Date(2012, 2,28), Date(2012, 3,28), dc) == ((28-28) + (3-2)*30 + (2012-2012)*360)/360
    @test frac(Date(2012, 2,29), Date(2012, 3,28), dc) == ((28-29) + (3-2)*30 + (2012-2012)*360)/360
    @test frac(Date(2012, 3, 1), Date(2012, 3,28), dc) == ((28-1) + (3-3)*30 + (2012-2012)*360)/360

    @test frac(Date(2012, 5,29), Date(2013, 8,29), dc) == ((29-29) + (8-5)*30 + (2013-2012)*360)/360
    @test frac(Date(2012, 5,29), Date(2013, 8,30), dc) == ((30-29) + (8-5)*30 + (2013-2012)*360)/360
    @test frac(Date(2012, 5,29), Date(2013, 8,31), dc) == ((31-29) + (8-5)*30 + (2013-2012)*360)/360
    @test frac(Date(2012, 5,30), Date(2013, 8,29), dc) == ((29-30) + (8-5)*30 + (2013-2012)*360)/360
    @test frac(Date(2012, 5,30), Date(2013, 8,30), dc) == ((30-30) + (8-5)*30 + (2013-2012)*360)/360
    @test frac(Date(2012, 5,30), Date(2013, 8,31), dc) == ((30-30) + (8-5)*30 + (2013-2012)*360)/360 # exception
    @test frac(Date(2012, 5,31), Date(2013, 8,29), dc) == ((29-30) + (8-5)*30 + (2013-2012)*360)/360 # exception
    @test frac(Date(2012, 5,31), Date(2013, 8,30), dc) == ((30-30) + (8-5)*30 + (2013-2012)*360)/360 # exception
    @test frac(Date(2012, 5,31), Date(2013, 8,31), dc) == ((30-30) + (8-5)*30 + (2013-2012)*360)/360 # exception

    # zeros
    @test frac(Date(2011,12,28), Date(2011,12,28), dc) == 0
    @test frac(Date(2011,12,31), Date(2011,12,31), dc) == 0
    @test frac(Date(2012, 2,28), Date(2012, 2,28), dc) == 0
    @test frac(Date(2012, 2,29), Date(2012, 2,29), dc) == 0
end

@testset "ThirtyE360" begin
    dc = ThirtyE360()
    # usual rule: ((d2-d1) + (m2-m1)*30 + (y2-y1)*360)/360
    @test frac(Date(2011,12,28), Date(2012, 2,28), dc) == ((28-28) + (2-12)*30 + (2012-2011)*360)/360
    @test frac(Date(2011,12,28), Date(2012, 2,29), dc) == ((29-28) + (2-12)*30 + (2012-2011)*360)/360
    @test frac(Date(2011,12,28), Date(2012, 3, 1), dc) == ((1-28) + (3-12)*30 + (2012-2011)*360)/360
    @test frac(Date(2011,12,28), Date(2016, 2,28), dc) == ((28-28) + (2-12)*30 + (2016-2011)*360)/360
    @test frac(Date(2011,12,28), Date(2016, 2,29), dc) == ((29-28) + (2-12)*30 + (2016-2011)*360)/360
    @test frac(Date(2011,12,28), Date(2016, 3, 1), dc) == ((1-28) + (3-12)*30 + (2016-2011)*360)/360
    @test frac(Date(2012, 2,28), Date(2012, 3,28), dc) == ((28-28) + (3-2)*30 + (2012-2012)*360)/360
    @test frac(Date(2012, 2,29), Date(2012, 3,28), dc) == ((28-29) + (3-2)*30 + (2012-2012)*360)/360
    @test frac(Date(2012, 3, 1), Date(2012, 3,28), dc) == ((28-1) + (3-3)*30 + (2012-2012)*360)/360

    @test frac(Date(2012, 5,29), Date(2013, 8,29), dc) == ((29-29) + (8-5)*30 + (2013-2012)*360)/360
    @test frac(Date(2012, 5,29), Date(2013, 8,30), dc) == ((30-29) + (8-5)*30 + (2013-2012)*360)/360
    @test frac(Date(2012, 5,29), Date(2013, 8,31), dc) == ((30-29) + (8-5)*30 + (2013-2012)*360)/360 # exception
    @test frac(Date(2012, 5,30), Date(2013, 8,29), dc) == ((29-30) + (8-5)*30 + (2013-2012)*360)/360
    @test frac(Date(2012, 5,30), Date(2013, 8,30), dc) == ((30-30) + (8-5)*30 + (2013-2012)*360)/360
    @test frac(Date(2012, 5,30), Date(2013, 8,31), dc) == ((30-30) + (8-5)*30 + (2013-2012)*360)/360 # exception
    @test frac(Date(2012, 5,31), Date(2013, 8,29), dc) == ((29-30) + (8-5)*30 + (2013-2012)*360)/360 # exception
    @test frac(Date(2012, 5,31), Date(2013, 8,30), dc) == ((30-30) + (8-5)*30 + (2013-2012)*360)/360 # exception
    @test frac(Date(2012, 5,31), Date(2013, 8,31), dc) == ((30-30) + (8-5)*30 + (2013-2012)*360)/360 # exception

    # zeros
    @test frac(Date(2011,12,28), Date(2011,12,28), dc) == 0
    @test frac(Date(2011,12,31), Date(2011,12,31), dc) == 0
    @test frac(Date(2012, 2,28), Date(2012, 2,28), dc) == 0
    @test frac(Date(2012, 2,29), Date(2012, 2,29), dc) == 0
end

@testset "ThirtyE360ISDA" begin
    @testset "maturity not end of Feb" begin
        dc = ThirtyE360ISDA(Date(2012, 8, 31))
        @test frac(Date(2011,12,28), Date(2012, 2,28), dc) == ((28-28) + (2-12)*30 + (2012-2011)*360)/360
        @test frac(Date(2011,12,28), Date(2012, 2,29), dc) == ((30-28) + (2-12)*30 + (2012-2011)*360)/360 # exception
        @test frac(Date(2011,12,28), Date(2012, 3, 1), dc) == ((1-28) + (3-12)*30 + (2012-2011)*360)/360
        @test frac(Date(2011,12,28), Date(2016, 2,28), dc) == ((28-28) + (2-12)*30 + (2016-2011)*360)/360
        @test frac(Date(2011,12,28), Date(2016, 2,29), dc) == ((30-28) + (2-12)*30 + (2016-2011)*360)/360 # exception
        @test frac(Date(2011,12,28), Date(2016, 3, 1), dc) == ((1-28) + (3-12)*30 + (2016-2011)*360)/360
        @test frac(Date(2012, 2,28), Date(2012, 3,28), dc) == ((28-28) + (3-2)*30 + (2012-2012)*360)/360
        @test frac(Date(2012, 2,29), Date(2012, 3,28), dc) == ((28-30) + (3-2)*30 + (2012-2012)*360)/360 # exception
        @test frac(Date(2012, 3, 1), Date(2012, 3,28), dc) == ((28-1) + (3-3)*30 + (2012-2012)*360)/360

        @test frac(Date(2012, 5,29), Date(2013, 8,29), dc) == ((29-29) + (8-5)*30 + (2013-2012)*360)/360
        @test frac(Date(2012, 5,29), Date(2013, 8,30), dc) == ((30-29) + (8-5)*30 + (2013-2012)*360)/360
        @test frac(Date(2012, 5,29), Date(2013, 8,31), dc) == ((30-29) + (8-5)*30 + (2013-2012)*360)/360 # exception
        @test frac(Date(2012, 5,30), Date(2013, 8,29), dc) == ((29-30) + (8-5)*30 + (2013-2012)*360)/360
        @test frac(Date(2012, 5,30), Date(2013, 8,30), dc) == ((30-30) + (8-5)*30 + (2013-2012)*360)/360
        @test frac(Date(2012, 5,30), Date(2013, 8,31), dc) == ((30-30) + (8-5)*30 + (2013-2012)*360)/360 # exception
        @test frac(Date(2012, 5,31), Date(2013, 8,29), dc) == ((29-30) + (8-5)*30 + (2013-2012)*360)/360 # exception
        @test frac(Date(2012, 5,31), Date(2013, 8,30), dc) == ((30-30) + (8-5)*30 + (2013-2012)*360)/360 # exception
        @test frac(Date(2012, 5,31), Date(2013, 8,31), dc) == ((30-30) + (8-5)*30 + (2013-2012)*360)/360 # exception

        # zeros
        @test frac(Date(2011,12,28), Date(2011,12,28), dc) == 0
        @test frac(Date(2011,12,31), Date(2011,12,31), dc) == 0
        @test frac(Date(2012, 2,28), Date(2012, 2,28), dc) == 0
        @test frac(Date(2012, 2,29), Date(2012, 2,29), dc) == 0
    end

    @testset "maturity end of Feb" begin
        dc = ThirtyE360ISDA(Date(2012, 2,29)) # leap year, end of month
        @test frac(Date(2011,12,28), Date(2012, 2,28), dc) == ((28-28) + (2-12)*30 + (2012-2011)*360)/360
        @test frac(Date(2011,12,28), Date(2012, 2,29), dc) == ((29-28) + (2-12)*30 + (2012-2011)*360)/360
        @test frac(Date(2011,12,28), Date(2012, 3, 1), dc) == ((1-28) + (3-12)*30 + (2012-2011)*360)/360
        @test frac(Date(2011,12,28), Date(2016, 2,28), dc) == ((28-28) + (2-12)*30 + (2016-2011)*360)/360
        @test frac(Date(2011,12,28), Date(2016, 2,29), dc) == ((30-28) + (2-12)*30 + (2016-2011)*360)/360 # exception
        @test frac(Date(2011,12,28), Date(2016, 3, 1), dc) == ((1-28) + (3-12)*30 + (2016-2011)*360)/360
        @test frac(Date(2012, 2,28), Date(2012, 3,28), dc) == ((28-28) + (3-2)*30 + (2012-2012)*360)/360
        @test frac(Date(2012, 2,29), Date(2012, 3,28), dc) == ((28-30) + (3-2)*30 + (2012-2012)*360)/360 # exception
        @test frac(Date(2012, 3, 1), Date(2012, 3,28), dc) == ((28-1) + (3-3)*30 + (2012-2012)*360)/360

        @test frac(Date(2012, 5,29), Date(2013, 8,29), dc) == ((29-29) + (8-5)*30 + (2013-2012)*360)/360
        @test frac(Date(2012, 5,29), Date(2013, 8,30), dc) == ((30-29) + (8-5)*30 + (2013-2012)*360)/360
        @test frac(Date(2012, 5,29), Date(2013, 8,31), dc) == ((30-29) + (8-5)*30 + (2013-2012)*360)/360 # exception
        @test frac(Date(2012, 5,30), Date(2013, 8,29), dc) == ((29-30) + (8-5)*30 + (2013-2012)*360)/360
        @test frac(Date(2012, 5,30), Date(2013, 8,30), dc) == ((30-30) + (8-5)*30 + (2013-2012)*360)/360
        @test frac(Date(2012, 5,30), Date(2013, 8,31), dc) == ((30-30) + (8-5)*30 + (2013-2012)*360)/360 # exception
        @test frac(Date(2012, 5,31), Date(2013, 8,29), dc) == ((29-30) + (8-5)*30 + (2013-2012)*360)/360 # exception
        @test frac(Date(2012, 5,31), Date(2013, 8,30), dc) == ((30-30) + (8-5)*30 + (2013-2012)*360)/360 # exception
        @test frac(Date(2012, 5,31), Date(2013, 8,31), dc) == ((30-30) + (8-5)*30 + (2013-2012)*360)/360 # exception

        # zeros
        @test frac(Date(2011,12,28), Date(2011,12,28), dc) == 0
        @test frac(Date(2011,12,31), Date(2011,12,31), dc) == 0
        @test frac(Date(2012, 2,28), Date(2012, 2,28), dc) == 0
        @test frac(Date(2012, 2,29), Date(2012, 2,29), dc) == 0
    end
end

@testset "ActualActualICMA" begin
    dc = ActualActualICMA(Date(2011,7,1):Month(6):Date(2012,7,1))

    # zeros
    @test frac(Date(2011,12,28), Date(2011,12,28), dc) == 0
    @test frac(Date(2011,12,31), Date(2011,12,31), dc) == 0
    @test frac(Date(2012, 2,28), Date(2012, 2,28), dc) == 0
    @test frac(Date(2012, 2,29), Date(2012, 2,29), dc) == 0
end

@testset "ActuaActual ISDA Memo" begin
    # these test cases are all derived from
    # The Actual/Actual Day Count Fraction, ISDA
    # Paper for use with the ISDA Market Conventions Survey - 3rd June 1999
    # https://www.isda.org/a/pIJEE/The-Actual-Actual-Day-Count-Fraction-1999.pdf

    @testset "Semi-annual payment" begin
        dc_isda = ActualActualISDA()
        dc_icma = ActualActualICMA(Date(2003,11,1):Month(6):Date(2004,5,1))
    end        
    
    @testset "short first" begin
        dc_isda = ActualActualISDA()
        dc_icma = ActualActualICMA(Date(1998,7,1):Month(12):Date(2000,7,1))

        @test frac(Date(1999,2,1), Date(1999,7,1), dc_isda) == 150/365
        @test frac(Date(1999,2,1), Date(1999,7,1), dc_icma) ≈ 150/365 atol=eps()

        @test frac(Date(1999,7,1), Date(2000,7,1), dc_isda) == 184/365 + 182/366
        @test frac(Date(1999,7,1), Date(2000,7,1), dc_icma) == 366/366

        @test frac(Date(1999,2,1), Date(2000,7,1), dc_isda) == (150 + 184)/365 + 182/366 
        @test frac(Date(1999,2,1), Date(2000,7,1), dc_icma) ≈ 150/365 + 366/366 atol=eps()
    end

    @testset "long first" begin
        dc_isda = ActualActualISDA()
        dc_icma = ActualActualICMA(Date(2002,7,15):Month(6):Date(2004,1,15))

        @test frac(Date(2002,8,15), Date(2003,7,15), dc_isda) == 334/365
        @test frac(Date(2002,8,15), Date(2003,7,15), dc_icma) == 181/(181*2) + 153/(184*2)

        @test frac(Date(2003,7,15),Date(2004,1,15), dc_isda) == 170/365 + 14/366
        @test frac(Date(2003,7,15), Date(2004,1,15), dc_icma) == 184/(184*2)

        @test frac(Date(2002,8,15), Date(2004,1,15), dc_isda) ≈ (334+170)/365 + 14/366 rtol=eps()
        @test frac(Date(2002,8,15), Date(2004,1,15), dc_icma) == 181/(181*2) + (153+184)/(184*2)
    end

    @testset "short final" begin
        dc_isda = ActualActualISDA()
        dc_icma = ActualActualICMA(Date(1999,7,30):Month(6):Date(2000,7,30))

        @test frac(Date(1999,7,30), Date(2000,1,30), dc_isda) == 155/365 + 29/366
        @test frac(Date(1999,7,30), Date(2000,1,30), dc_icma) == 184/(184*2)

        @test frac(Date(2000,1,30), Date(2000,6,30), dc_isda) == 152/366
        @test frac(Date(2000,1,30), Date(2000,6,30), dc_icma) == 152/(182*2)

        @test frac(Date(1999,7,30), Date(2000,6,30), dc_isda) == 155/365 + (29+152)/366
        @test frac(Date(1999,7,30), Date(2000,6,30), dc_icma) == 184/(184*2) + 152/(182*2)
    end

    @testset "long final" begin
        dc_isda = ActualActualISDA()
        # TODO: need a way to express "last day of month" schedules.
        dc_icma = ActualActualICMA(Date(1999,5,31):Month(3):Date(2000,5,31))

        @test frac(Date(1999,11,30), Date(2000,4,30), dc_isda) == 32/365 + 120/366
        @test frac(Date(1999,11,30), Date(2000,4,30), dc_icma) == 91/(91*4) + 61/(92*4)
    end
end


@testset "Thirty360Excel" begin
    dc = Thirty360Excel()
    # usual rule: ((d2-d1) + (m2-m1)*30 + (y2-y1)*360)/360
    @test frac(Date(2011,12,28), Date(2012, 2,28), dc) == ((28-28) + (2-12)*30 + (2012-2011)*360)/360
    @test frac(Date(2011,12,28), Date(2012, 2,29), dc) == ((29-28) + (2-12)*30 + (2012-2011)*360)/360
    @test frac(Date(2011,12,28), Date(2012, 3, 1), dc) == ((1-28) + (3-12)*30 + (2012-2011)*360)/360
    @test frac(Date(2011,12,28), Date(2016, 2,28), dc) == ((28-28) + (2-12)*30 + (2016-2011)*360)/360
    @test frac(Date(2011,12,28), Date(2016, 2,29), dc) == ((29-28) + (2-12)*30 + (2016-2011)*360)/360
    @test frac(Date(2011,12,28), Date(2016, 3, 1), dc) == ((1-28) + (3-12)*30 + (2016-2011)*360)/360
    @test frac(Date(2012, 2,28), Date(2012, 3,28), dc) == ((28-28) + (3-2)*30 + (2012-2012)*360)/360
    @test frac(Date(2012, 2,29), Date(2012, 3,28), dc) == ((28-30) + (3-2)*30 + (2012-2012)*360)/360 # exception
    @test frac(Date(2012, 3, 1), Date(2012, 3,28), dc) == ((28-1) + (3-3)*30 + (2012-2012)*360)/360

    @test frac(Date(2012, 5,29), Date(2013, 8,29), dc) == ((29-29) + (8-5)*30 + (2013-2012)*360)/360
    @test frac(Date(2012, 5,29), Date(2013, 8,30), dc) == ((30-29) + (8-5)*30 + (2013-2012)*360)/360
    @test frac(Date(2012, 5,29), Date(2013, 8,31), dc) == ((31-29) + (8-5)*30 + (2013-2012)*360)/360
    @test frac(Date(2012, 5,30), Date(2013, 8,29), dc) == ((29-30) + (8-5)*30 + (2013-2012)*360)/360
    @test frac(Date(2012, 5,30), Date(2013, 8,30), dc) == ((30-30) + (8-5)*30 + (2013-2012)*360)/360
    @test frac(Date(2012, 5,30), Date(2013, 8,31), dc) == ((30-30) + (8-5)*30 + (2013-2012)*360)/360 # exception
    @test frac(Date(2012, 5,31), Date(2013, 8,29), dc) == ((29-30) + (8-5)*30 + (2013-2012)*360)/360 # exception
    @test frac(Date(2012, 5,31), Date(2013, 8,30), dc) == ((30-30) + (8-5)*30 + (2013-2012)*360)/360 # exception
    @test frac(Date(2012, 5,31), Date(2013, 8,31), dc) == ((30-30) + (8-5)*30 + (2013-2012)*360)/360 # exception

    # zeros
    @test frac(Date(2011,12,28), Date(2011,12,28), dc) == 0
    @test frac(Date(2011,12,31), Date(2011,12,31), dc) == 0
    @test frac(Date(2012, 2,28), Date(2012, 2,28), dc) == 0
    @test frac(Date(2012, 2,29), Date(2012, 2,29), dc) == 0
end



@testset "ActualActualExcel" begin
    dc = ActualActualExcel()
    # calculated from Excel sheet
    @test frac(Date(2011,12,28), Date(2012, 2,28), dc) == 62/365
    @test frac(Date(2011,12,28), Date(2012, 2,29), dc) == 63/366
    @test frac(Date(2011,12,28), Date(2012, 3, 1), dc) == 64/366
    @test frac(Date(2011,12,28), Date(2016, 2,28), dc) == 1523/365.3333333333333
    @test frac(Date(2011,12,28), Date(2016, 2,29), dc) == 1524/365.3333333333333
    @test frac(Date(2011,12,28), Date(2016, 3, 1), dc) == 1525/365.3333333333333
    @test frac(Date(2012, 2,28), Date(2012, 3,28), dc) == 29/366
    @test frac(Date(2012, 2,29), Date(2012, 3,28), dc) == 28/366
    @test frac(Date(2012, 3, 1), Date(2012, 3,28), dc) == 27/366

    @test frac(Date(2012, 2,28), Date(2013, 2,28), dc) == 366/366
    @test frac(Date(2012, 2,29), Date(2013, 2,28), dc) == 365/366
    @test frac(Date(2012, 3, 1), Date(2013, 2,28), dc) == 364/365
    @test frac(Date(2012, 2,28), Date(2013, 3, 1), dc) == 367/365.5
    @test frac(Date(2012, 2,29), Date(2013, 3, 1), dc) == 366/365.5
    @test frac(Date(2012, 3, 1), Date(2013, 3, 1), dc) == 365/365
    
    @test frac(Date(2011, 2,28), Date(2012, 2,28), dc) == 365/365
    @test frac(Date(2011, 3, 1), Date(2012, 2,28), dc) == 364/365
    @test frac(Date(2011, 2,28), Date(2012, 2,29), dc) == 366/365.5
    @test frac(Date(2011, 3, 1), Date(2012, 2,29), dc) == 365/366
    @test frac(Date(2011, 2,28), Date(2012, 3, 1), dc) == 367/365.5
    @test frac(Date(2011, 3, 1), Date(2012, 3, 1), dc) == 366/366

    # zeros
    @test frac(Date(2011,12,28), Date(2011,12,28), dc) == 0
    @test frac(Date(2011,12,31), Date(2011,12,31), dc) == 0
    @test frac(Date(2012, 2,28), Date(2012, 2,28), dc) == 0
    @test frac(Date(2012, 2,29), Date(2012, 2,29), dc) == 0
end

@testset "ActualActualISMA" begin
    dc = ActualActualISMA()
    # The following two test cases are derived from:
    # Accrued interest – a guide for private investors, January 2015, page 2.
    # Published by the London Stock Exchange Group:
    # https://www.londonstockexchange.com/traders-and-brokers/security-types/retail-bonds/accrued-interest-corp-supra.pdf
    @test frac(Date(2014,11,26), Date(2015, 4,1), Date(2015,11,26), dc) == 126/(365 * 1)  # annual coupon
    @test frac(Date(2015, 3, 7), Date(2015, 4,9), Date(2015, 9, 7), dc) ==  33/(184 * 2)  # semi-annual coupoun
    
    # zeros
    @test frac(Date(2012, 2,28), Date(2012, 2,28), Date(2012, 8,28), dc) == 0
    @test frac(Date(2012, 2,29), Date(2012, 2,29), Date(2012, 8,28), dc) == 0
end

# Dates for the swap example from http://www.derivativepricing.com/blogpage.asp?id=19: 
# Effective Date (Start Date): Feb 28, 2008
# Maturity Date (End Date): Feb 28, 2011
# Frequency: Semi-Annual
@testset "Todos os dias são Dias Úteis: AllBD" begin
    @test utild(Date(2019, 12, 25),  AllBD, :USNYSE) == Date(2019,  12, 25) 
    @test utild(Date(2019, 12, 25),  AllBD) == Date(2019,  12, 25) 
end

@testset "Convenção Dias Úteis: Following" begin
    @test utild(Date(2019, 2, 23),    Following, :USNYSE) == Date(2019,  2, 25)   
end
@testset "Following: Contrato de Swap" begin
    @test utild(Date(2008, 2, 28), Following, :USNYSE) == Date(2008,  2, 28)  
    @test utild(Date(2008, 8, 28), Following, :USNYSE) == Date(2008,  8, 28)  
    @test utild(Date(2009, 2, 28), Following, :USNYSE) == Date(2009,  3,  2)
    @test utild(Date(2009, 8, 28), Following, :USNYSE) == Date(2009,  8, 28)
    @test utild(Date(2010, 2, 28), Following, :USNYSE) == Date(2010,  3,  1)
    @test utild(Date(2010, 8, 28), Following, :USNYSE) == Date(2010,  8, 30)
    @test utild(Date(2011, 2, 28), Following, :USNYSE) == Date(2011,  2, 28)
end  

@testset "Convenção Dias Úteis: Modified Following" begin
    @test utild(Date(2019, 2, 23),    ModifiedFollowing, :USNYSE) == Date(2019,  2, 25)   
end
@testset "Modified Following: Contrato de Swap" begin
    @test utild(Date(2008, 2, 28), ModifiedFollowing, :USNYSE) == Date(2008,  2, 28)  
    @test utild(Date(2008, 8, 28), ModifiedFollowing, :USNYSE) == Date(2008,  8, 28)  
    @test utild(Date(2009, 2, 28), ModifiedFollowing, :USNYSE) == Date(2009,  2, 27)   
    @test utild(Date(2009, 8, 28), ModifiedFollowing, :USNYSE) == Date(2009,  8, 28)
    @test utild(Date(2010, 2, 28), ModifiedFollowing, :USNYSE) == Date(2010,  2, 26)    
    @test utild(Date(2010, 8, 28), ModifiedFollowing, :USNYSE) == Date(2010,  8, 30)
    @test utild(Date(2011, 2, 28), ModifiedFollowing, :USNYSE) == Date(2011,  2, 28)
end  
# Note how in coupon #2 and #4 the dates are adjusted to the previous business date. While coupon #5 was adjusted to the next good business date. 
@testset "Convenção Dias Úteis: Preceding" begin
    @test utild(Date(2019, 2, 23),    Preceding, :USNYSE) == Date(2019,  2, 22)   
end
@testset "Convenção Dias Úteis: ModifiedPreceding" begin
    @test utild(Date(2019, 2, 23),    Preceding, :USNYSE) == Date(2019,  2, 22)   
end
@testset "Convenção Dias Úteis: EndOfMonth (Unadjusted)" begin
    @test utild(Date(2019, 2, 23),     EndOfMonth) == Date(2019,  2, 28)   
    @test utild(Date(2020, 2, 23),     EndOfMonth) == Date(2020,  2, 29) 
    @test utild(Date(2020, 2, 29),     EndOfMonth) == Date(2020,  2, 29)    
end
@testset "EndOfMonth (Unadjusted): Contrato de Swap" begin
    @test utild(Date(2008, 2, 28),  EndOfMonth) == Date(2008,  2, 29)  
    @test utild(Date(2008, 8, 28),  EndOfMonth) == Date(2008,  8, 31)  
    @test utild(Date(2009, 2, 28),  EndOfMonth) == Date(2009,  2, 28)
    @test utild(Date(2009, 8, 28),  EndOfMonth) == Date(2009,  8, 31)
    @test utild(Date(2010, 2, 28),  EndOfMonth) == Date(2010,  2, 28)
    @test utild(Date(2010, 8, 28),  EndOfMonth) == Date(2010,  8, 31)
    @test utild(Date(2011, 2, 28),  EndOfMonth) == Date(2011,  2, 28)
end 
@testset "Convenção Dias Úteis: Aplicada a Matriz de Datas" begin
    A = [Date(2019,3,2) 0.05; Date(2019,3,4) 0.07; Date(2019,3,5) 0.02]
    B = [Date(2019,3,2) 0.05; Date(2019,3,4) 0.07; Date(2019,3,5) 0.02]
    @test bdarray(A, Following, :TARGET)[1,1] == Date(2019,3,4)
    @test bdarray(B, Following, :TARGET, [1])[1,1] == Date(2019,3,4)
end
@testset "Fluxos Caixa Obrigação: Com e Sem Amortização do Principal" begin
    a = fcaixa(Date(2019,3,3), Date(2021,3,12), 0.05, 2, principal = 1000)
    @test size(a) == (5,2)
    @test a[1,1] == Date(2021,3,12)
    @test a[3,1] == Date(2020,3,12)
    @test a[1,2] == 1025.0
    @test a[3,2] ==   25.0

    b = fcaixa(Date(2019,3,3), Date(2021,3,12), 0.05, 2, 100, principal = 1000)
    @test size(b) == (5,2)
    @test b[1,1] == Date(2021,3,12)
    @test b[3,1] == Date(2020,3,12)
    @test b[1,2] == 102.49999999999999
    @test b[3,2] == 107.5
end
@testset "z-spread de uma obrigação" begin
    price = 102.30
    cf = [3.50, 103.50]
    m = [0.589, 1.589]
    r = [0.0020, 0.0035]
    z = 0.025390646751015725
    compos = Continuous   # composição contínua
    @test spreço(cf,m,r, z, compos) == 102.30
    @test zspread(price, cf, m, r, compos) == 0.02539064675101572
end
@testset "dirty price <-> yield-to-maturity: Formula normal" begin
    preço = 108.185342
    fck = [2.20, 2.20, 2.20, 2.20, 102.20]
    tk = [0.665753, 1.665753, 2.67122, 3.66848, 4.66574]
    y = 0.005767516967531196
    compos = Discrete   # composição discreta
    @test spreço(fck,tk, y, compos) == 108.18534199999998
    @test ytm(preço, fck, tk, compos) == 0.005767516967531196
end


