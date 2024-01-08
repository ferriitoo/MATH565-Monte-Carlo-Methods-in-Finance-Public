%% Problem 1a
% We take the sample code and change its variables into the ones required
% in the exercise. (initial price =$30, i= 1%, volatility = 40%, time is
% weekly for four weeks.
% Exercise 1a requires us to price the Asian Arithmetic Mean call option
% with the previously selected parameters, plus a strike price of $30 and an
% absolute error of +-$0.1

%% Initialization
% First we set up the basic common praramters for our examples.

%function BarrierUpInCall = HW4_1 %make it a function to avoid variable conflicts

% We fix the seed to have similar results in simulations
rng(8)

gail.InitializeDisplay %initialize the workspace and the display parameters
inp.timeDim.timeVector = 1/52:1/52:6/52; %weekly monitoring for six weeks
inp.assetParam.initPrice = 30; %initial stock price
inp.assetParam.interest = 0.01; %risk-free interest rate
inp.assetParam.volatility = 0.4; %volatility
inp.payoffParam.strike = 30; %strike price
inp.priceParam.absTol = 0.1; %absolute tolerance of 10 cents
inp.priceParam.relTol = 0; %zero relative tolerance
EuroCall = optPrice(inp) %construct an optPrice object 

%%
% Note that the default is a European call option.  Its exact price is
% coded in

disp(['The price of this European call option is $' num2str(EuroCall.exactPrice)])

%% Arithmetic Mean Options
% The payoff of the arithmetic mean option depends on the average of the
% stock price, not the final stock price.  Here are the discounted payoffs:
%
% \[
% \begin{array}{rcc}
% & \textbf{call} & \textbf{put} \\ \hline
% \textbf{payoff} & 
% \displaystyle \max\biggl(\frac 1d \sum_{j=1}^d S(jT/d) - K,0 \biggr)\mathsf{e}^{-rT} & 
% \displaystyle \max\biggl(K - \frac 1d \sum_{j=1}^d S(jT/d),0 \biggr)\mathsf{e}^{-rT} 
% \end{array}
% \]

%%
% To construct price this option, we construct an |optPrice| object with
% the correct properties.  First we make a copy of our original |optPrice|
% object.  Then we change the properties that we need to change.

ArithMeanCall = optPrice(EuroCall); %make a copy
ArithMeanCall.payoffParam.optType = {'amean'} %change from European to Asian arithmetic mean

%%
% Next we generate the price using the |genOptPrice| method of the |optPrice|
% object. 

[ArithMeanCallPrice,out] = genOptPrice(ArithMeanCall); %uses meanMC_g to compute the price
disp(['The price of this Asian arithmetic mean call option is $' num2str(ArithMeanCallPrice) ...
   ' +/- $' num2str(max(ArithMeanCall.priceParam.absTol, ...
   ArithMeanCall.priceParam.relTol*ArithMeanCallPrice)) ])
disp(['   and it took ' num2str(out.time) ' seconds and ' ...
   num2str(out.nPaths) ' paths to compute']) %display results nicely

%%Problem 1b
%% The Arithmetic Call *with* control variates
% To use control variates we need to set up an |optPayoff| object with
% _two_ or more payoffs, the one whose expectation we want to compute, and the
% control variate(s)

ArithEuro = optPayoff(ArithMeanCall)
ArithEuro.payoffParam = ...
   struct('optType',{{'amean','euro'}}, ... %note two kinds of option payoffs
   'putCallType', {{'call','call'}}) %this needs to have the same dimension

%%
% Now we call |meanMC_g|:

[ArithEuroPrice, AEout] = meanMC_g(@(n) YoptPrice_CV(ArithEuro,n), ...
   inp.priceParam.absTol, inp.priceParam.relTol)
disp(['The price of the Asian arithmetic mean call option is $' ...
   num2str(ArithEuroPrice,'%5.2f')])
disp(['   and this took ' num2str(AEout.ntot) ' paths and ' ...
   num2str(AEout.time) ' seconds'])
disp(['   which is ' num2str(AEout.ntot/out.nPaths) ...
   ' of the paths and ' num2str(AEout.time/out.time) ' of the time'])
disp('      without Control Variates')

% We see that in this case, we reduced the number of paths by approximately
% 40%, but we have increased the time 2 fold, and that is because of the
% additional computation required to process the control variate.
% When we decrease the tolerance, i.e. to 0.01, (increasing the number of paths for
% both), the contol variates uses 40% less time and 40% less time, as the
% constant time needed by the control variate calculation becomes less
% important in relation to the time for path processing.

%% Problem 1c
% We firstly create the variable, we initialize it copying the original one
ArithPriceAnti = optPayoff(ArithMeanCall)


[ArithPriceAnti, AAntiout] = meanMC_g(@(n) YoptPrice_Anti(ArithMeanCall,n), ...
   inp.priceParam.absTol, inp.priceParam.relTol);
disp(['The price of the Asian arithmetic mean put option is $' ...
   num2str(ArithPriceAnti,'%5.2f')])
disp(['   and this took ' num2str(AAntiout.ntot) ' paths and ' ...
   num2str(AAntiout.time) ' seconds'])
disp(['   which is ' num2str(AAntiout.ntot/out.nPaths) ...
   ' of the paths and ' num2str(AAntiout.time/out.time) ' of the time'])
disp('      without antithetic variates')

% We see that in this case, we reduced the number of paths by approximately
% 40%, but we have increased the time +70% , and that is because of the
% additional computation required to process the Anthithetic Variates.
% When we decrease the tolerance, i.e. to 0.001, (increasing the number of paths for
% both), the Anthithetic Variates uses 81% less paths and 82% less time, as the
% constant time needed by the Anthithetic variate calculation becomes less
% important in relation to the time for path processing.

