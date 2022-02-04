// A randomwalk model for FIMS TMB exercises
#include <TMB.hpp>

template<class Type>
  Type objective_function<Type>::operator() ()
{
  /* Data section */
  DATA_VECTOR(y);
  DATA_VECTOR_INDICATOR(keep, y);  // For one-step predictions
  
  /* Parameter section */
  PARAMETER_VECTOR(u);
  PARAMETER(sigma_proc);
  PARAMETER(sigma_obs);
  PARAMETER(mu);
  
  /* Procedure section */
  int timeSteps=y.size();
  
  vector<Type> eta(timeSteps);
  
  for(int i=1;i<timeSteps;i++){
    eta[i] = mu + u[i-1];
  }
  
  Type nll = 0.0;
  
  for(int i=1;i<timeSteps;i++){
    nll -= dnorm(u[i], eta[i], sigma_proc, 1);
  }
  
  for(int i=0;i<timeSteps;i++){
    // nll -= dnorm(y[i], u[i], sigma_obs, 1);
    nll -= keep[i] * dnorm(y[i], u[i], sigma_obs, true);
  }
  
  SIMULATE {
    y = rnorm(u, sigma_obs);  // Simulate response
    REPORT(y);          // Report the simulation
  }
  
  REPORT(eta);
  ADREPORT(eta);

  REPORT(u);
  ADREPORT(u);

  REPORT(sigma_obs);
  ADREPORT(sigma_obs);

  REPORT(sigma_proc);
  ADREPORT(sigma_proc);
  
  return nll;
}
