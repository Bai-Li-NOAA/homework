setwd("~/Documents/Github/homework/fims_tmb_exercise")

library(TMB)
compile("randomwalk.cpp")
dyn.load(dynlib("randomwalk"))

## Read data
mu <- 0.75
sigma_proc <- 1
sigma_obs <- 1

sim_num <- 200
set.seed(999)
eta <- u <- rep(NA, sim_num)
u[1] <- rnorm(n = 1, mean = 0, sd = sigma_proc)
for (i in 2:sim_num) {
  eta[i] <- mu + u[i - 1]
  u[i] <- rnorm(1, eta[i], sigma_proc)
}
y <- rnorm(sim_num, u, sigma_obs)
data <- list(y = y)

## Parameter initial guess
parameters <- list(
  u = y,
  sigma_proc = 1,
  sigma_obs = 1,
  mu = 0.7
)

## Fit model
obj <- MakeADFun(data, parameters, random = "u", DLL = "randomwalk")
newtonOption(obj, smartsearch = FALSE)
obj$fn()
obj$gr()
system.time(opt <- nlminb(obj$par, obj$fn, obj$gr))
rep <- sdreport(obj)
rep

## Simulation
set.seed(1)
obj$simulate()

plot(obj$simulate()$y, y,
  xlab = "TMB simulated y",
  ylab = "R simulated y"
)

## Validation
u <- c(0, cumsum(rnorm(sim_num - 1, mean = mu, sd = sigma_proc)))
y <- u + rnorm(sim_num, sd = sigma_obs)

data <- list(y = y)
parameters <- list(u = u, sigma_proc = sigma_proc, sigma_obs = sigma_obs, mu = 0)

obj <- MakeADFun(data, parameters, random = c("u"), DLL = "randomwalk", map = list(mu = factor(NA)))
opt <- do.call("optim", obj)
sdr <- sdreport(obj)
estu <- summary(sdr, "random")

plot(u, type = "l", xlab = "Time", ylab = "u", lwd = 3)
points(y)
lines(estu[, 1], lwd = 1, col = "red")

resid <- y - estu[, 1]
Norm.resid <- resid / estu[, 2]
acf <- acf(Norm.resid, plot = FALSE)
predict <- oneStepPredict(obj, observation.name = "y", data.term.indicator = "keep", method = "oneStepGeneric")
qqnorm(predict$residual)
abline(0, 1)
ks.test(predict$residual, "pnorm")
