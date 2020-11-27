#' Members of the 115th Congress
#'
#' The biographical information of the members is taken from an archived
#' version of the `current-legislators` data from the UnitedStates.io project.
#' The ideology and leadership scores are taken from GovTrack, which bases their
#' analysis on the bills introduced and cosponsored by members.
#'
#' @format A data frame with 534 rows and 9 variables:
#' \describe{
#'   \item{name}{Legislator full name}
#'   \item{gid}{Unique GovTrack ID number}
#'   \item{birth}{Birth date}
#'   \item{race}{District or senate state and class code}
#'   \item{party}{Political party}
#'   \item{gender}{Identifying gender}
#'   \item{chamber}{Chamber of Congress: House or Senate}
#'   \item{ideology}{Left-Right (0-1) ideology score from pattern of cosponsorship}
#'   \item{leadership}{Leadership score based on frequency of cosponsored bills}
#'   ...
#' }
#' @source <https://theunitedstates.io/congress-legislators>
"members115"

#' Daily trading prices of 112 competitive 2018 Midterm races
#'
#' The opening, low, high, and closing prices of contracts tied to a party
#' winning a midterm race. Equilibrium prices reflect outcome probability.
#'
#' Prediction markets generate probabilistic forecasts by crowd-sourcing the
#' collection of data from self-interested and risk averse traders. The
#' efficient market hypothesis holds that asset prices reflect all available
#' information (including forecasting models).
#'
#' PredictIt is an exchange run by Victoria University of Wellington, New
#' Zealand. The site offers a continuous double-auction exchange, where traders
#' buy and sell shares of futures contracts tied to election outcomes. As a
#' trader’s perception of probabilities changes, they can sell those shares. The
#' market equilibrium price updates accordingly to reflect current probability.
#' As outcomes become more likely, prices rise as demand for shares increases.
#' Market data for all midterm prices was provided for academic purposes.
#'
#' @format A data frame with 41,933 rows and 9 variables:
#' \describe{
#'   \item{date}{Prediction date}
#'   \item{mid}{Market ID}
#'   \item{race}{Unique race code}
#'   \item{party}{Contract party}
#'   \item{open}{Opening contract price for day}
#'   \item{low}{Low contract price for day}
#'   \item{high}{High contract price for day}
#'   \item{close}{Closing contract price for day}
#'   \item{volume}{Nunber of contract shares traded}
#'   ...
#' }
#' @source <https://www.predictit.org/>
"markets18"

#' Daily forecast probabilities of all 2018 Midterm races
#'
#' The election forecast probabilities from the 2018 FiveThirtyEight "classic"
#' midterm model. Probabilities are taken by estimating vote share and a
#' probability distribution from historical data.
#'
#' As Nate Silver explains, most forecasting models (1) “take lots of polls,
#' perform various types of adjustments to them, and then blend them with other
#' kinds of empirically useful indicators to forecast each race”. Importantly,
#' they (2) “account for the uncertainty in the forecast and simulate the
#' election thousands of times” to generate a probabilistic forecast.
#'
#' The classic model incorporates three types of inputs, primarily direct and
#' imputed polling as well as fundamentals factors like incumbency and the
#' generic ballot.
#'
#' @format A data frame with 1,049 rows and 11 variables:
#' \describe{
#'   \item{date}{Prediction date}
#'   \item{race}{Unique race code}
#'   \item{name}{Candidate name}
#'   \item{party}{Candidate party}
#'   \item{chamber}{Chamber of Congress: House or Senate}
#'   \item{special}{Is this election a special election?}
#'   \item{incumbent}{Is the candidate the incumbent?}
#'   \item{prob}{Probability candidate wins}
#'   \item{voteshare}{Median estimated share of vote}
#'   \item{min_share}{10th percentile vote share}
#'   \item{max_share}{90th percentile vote share}
#'   ...
#' }
#' @source <https://fivethirtyeight.com/>
"model18"

#' 2018 Midterm race results
#'
#' @format A data frame with 468 rows and 6 variables:
#' \describe{
#'   \item{year}{Election year}
#'   \item{race}{Unique race code}
#'   \item{lean}{The average difference between how a state or district votes
#'   and how the country votes overall}
#'   \item{category}{Ordinal race category: safe > solid > likely > lean > tilt}
#'   \item{winner}{`TRUE` if Democrat won, `FALSE` if Republican}
#'   \item{party}{Incumbent party}
#'   ...
#' }
#' @source <https://fivethirtyeight.com/>
"results18"
