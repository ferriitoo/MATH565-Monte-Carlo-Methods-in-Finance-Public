# First problem

# Statement:
# For these next problems use the GAIL software and consider a stock with an initial price of $30, an interest rate of 1%, and a volatility of 40%, being monitored weekly for 6 weeks.

# Answer:

# The initial values of the variables must be set as follows:
i= 1% 
Strike price for Asian = 30$
volatility = 40%
Admitted error = +-0.1
# Monitoring during 6 weeks

# a) Asian Arithmetic Mean call option
# Establishing the values of some initial parameters

gail.InitializeDisplay %initializing
inp.assetParam.initPrice = 30; %initial price
inp.assetParam.volatility = 0.4; 
inp.payoffParam.strike = 30; %strike price
inp.assetParam.interest = 1/100; %setting up interest rate
inp.timeDim.timeVector = 1/52:1/52:6/52; %monitoring during six weeks
inp.priceParam.relTol = 0; %the relative error has nothing to do, the criteria will be the absolute error
inp.priceParam.absTol = 0.1; %setting up the absolute error
EuropeanCall = optPrice(inp)  


# Arithmetic Mean Options
# With regards to other kind of options, the payoff of the the arithmetic Asian Mean Option depends on the path of the stock price, not only in the last value of the stock price.  

# For the Asian Mean Option the original object is copied and some properties are changed.

ArithMeanCall = optPrice(EuropeanCall); %copying
ArithMeanCall.payoffParam.optType = {'amean'} 
[ArithMeanCallPrice,out] = genOptPrice(ArithMeanCall); 
disp(['The price of the Asian Mean Call option is $' num2str(ArithMeanCallPrice) ' +- ' num2str(max(ArithMeanCall.priceParam.absTol, ArithMeanCall.priceParam.relTol*ArithMeanCallPrice)) ])
disp([num2str(out.time) ' seconds were needed for computing and ' num2str(out.nPaths) ' paths were worked out']) 

# b) In this part of the exercise a European Call Option will be used as control variate in order to asses wether if having a control variate helps to save any time or paths in the workout. 

# Declaringthe Arithmetic Mean Call by using an European Call Options as control variate.

ArithEuro = optPayoff(ArithMeanCall)
ArithEuro.payoffParam = struct('optType',{{'amean','euro'}},'putCallType', {{'call','call'}}) 

# Using the |meanMC_g| function given by the GAIL library:

[ArithEuroPrice, AEout] = meanMC_g(@(n) YoptPrice_CV(ArithEuro,n), inp.priceParam.absTol, inp.priceParam.relTol)
disp(['The price of the Asian Mean Call option is $' num2str(ArithEuroPrice,'%5.2f')])
disp([ num2str(AEout.time) ' seconds were needed for computing and ' num2str(AEout.ntot) ' paths were computed ' ])

# Therefore, by using an European Call Option as control variate, we reduced the number of paths computed. Nevertheless, there has been a trade-off between the computed paths vs the computation time, because the computation time has increased due to the fact that the control variate has been integrated into the software. 

# c) In this third part of the exercise, instead of assesing the savings in paths or computing time by using a control variate, an antithetic variate will be used in order to do so.

ArithPriceAnti = optPayoff(ArithMeanCall)
[ArithPriceAnti, AAntiout] = meanMC_g(@(n) YoptPrice_Anti(ArithMeanCall,n), inp.priceParam.absTol, inp.priceParam.relTol);
disp(['The price of the Asian Mean put option is $' num2str(ArithPriceAnti,'%5.2f')])
disp([ num2str(AAntiout.ntot) ' paths were computed and ' num2str(AAntiout.time) ' seconds were needed fo rthe calculation'])

# For this third case, it goes the same way as it goes in the second one. Path number is reduced, but due to the trade-off between path numbers and computation time when adding more calculations, the computational time of the algorithm has been increased in order to perform the tasks related to the Anthitetic Variate.