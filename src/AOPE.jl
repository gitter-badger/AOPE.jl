__precompile__(true)

module AOPE

using Dates, BusinessDays, Roots
# using LinearAlgebra
using Reexport
@reexport using Dates
@reexport using Roots

export 
# Types
  Following,           # bd-conventions.jl
  ModifiedFollowing,   # bd-conventions.jl
  Preceding,           # bd-conventions.jl
  ModifiedPreceding,   # bd-conventions.jl
  EndOfMonth,          # bd-conventions.jl
  AllBD,               # bd-conventions.jl
  ActualActualISDA,    # dc-conventions.jl
  ActualActualICMA,    # dc-conventions.jl
  ActualActualISMA,    # bd-conventions.jl
  ActualActualExcel,   # dc-conventions.jl
  Actual365Fixed,      # dc-conventions.jl
  Actual360,           # dc-conventions.jl
  Thirty360,           # dc-conventions.jl
  ThirtyE360,          # dc-conventions.jl
  ThirtyE360ISDA,      # dc-conventions.jl
  Thirty360Excel,      # dc-conventions.jl
  Discrete,            # AOPE.jl
  Continuous,          # AOPE.jl

# Functions
  #transpose,   # LinearAlgebra.jl
  #det,         # LinearAlgebra.jl 
  #diag,        # LinearAlgebra.jl
  #pinv,        # LinearAlgebra.jl
  liqd,         # bd-conventions.jl
  frac,         # dc-conventions.jl
  utild,        # bd-conventions.jl
  bdarray,      # bd-conventions.jl
  nfcaixa,      # valuation.jl
  fcaixa,       # valuation.jl
  spreço,       # valuation.jl
  yca,          # yields.jl
  ytm,          # yields.jl
  ytmisda,      # yields.jl
  zspread       # yields.jl
  
# Operators
  #\,           # LinearAlgebra.jl
  #/,           # LinearAlgebra.jl

  # Constants
  #I            # LinearAlgebra.jl

abstract type Composition end

struct Discrete <: Composition end
struct Continuous <: Composition end

const D = Discrete
const C = Continuous
#const uteis = bd 
#const spreço = bondprice
#const ysimples = simpleyield
#const nfcaixa = nfc
#const fcaixa = fc


include("dc-conventions.jl")
include("excel-conventions.jl")
include("bd-conventions.jl")
include("valuation.jl")
include("yields.jl")


println("\nMestrado Análise Financeira: AOPE|2019 - versão 0.1.0 <2019-03-05>\n")

end # module AOPE
