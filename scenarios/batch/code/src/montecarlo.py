import pandas as pd
import numpy as np
#import matplotlib.pyplot as plt
#from scipy.interpolate import interp2d, interp1d
from datetime import date
import time
import logging
from applicationinsights import TelemetryClient
from applicationinsights.logging import LoggingHandler

import xmlutils

#-- Montecarlo

def mc_simulation(fx1, sigma1, drift, v, ro, maturity, t_steps, trials):

    dt = float(maturity) / t_steps  # defining time step
    ndt = np.zeros((t_steps + 1, trials), np.float64)    # place holder array for time step counter
    ndt[0] = 0

    fx_simulation = np.zeros((t_steps + 1, trials), np.float64)  # place holder array for simulated FX paths
    stoh_vol = np.zeros((t_steps + 1, trials), np.float64)  # place holder array for simulated volatilities

    stoh_vol[0] = sigma1  # setting volatility value at t = 0
    fx_simulation[0] = fx1  # setting FX value at t = 0

    # loc_vol = np.zeros((t_steps + 1, trials), np.float64)  # place holder array for simulated local volatility
    # loc_vol[0] = 1  # setting local volatility value at t = 0

    for t in range(1, t_steps+1):
        ndt[t] = ndt[t - 1] + dt  # counting time steps

        random_num_2 = np.random.standard_normal(trials)  # drawing random numbers for stochastic volatility process
        random_num_1 = np.random.standard_normal(trials)  # drawing random numbers for FX process

        stoh_vol[t] = stoh_vol[t-1] * np.exp((-0.5 * v ** 2) * dt + v * (ro * random_num_1 + np.sqrt(1-ro ** 2) *
        random_num_2) * np.sqrt(dt))   # stochastic volatility process

        #print(stoh_vol[t,0])
        fx_simulation[t] = fx_simulation[t - 1] * np.exp((drift - 0.5 * stoh_vol[t] ** 2) * dt + stoh_vol[t] *
                                                         random_num_1 * np.sqrt(dt))

    return fx_simulation, stoh_vol, ndt

def price_option(inputs):

    #print("price_option")
    #print(inputs)
    start_time = time.time()
    ''' Monte Carlo Model Parameters '''
    fx1 = inputs['fx1']
    # EURGBP as of 29/12/2017: 0.888085  for FX High: 0.88944 FX Low: 0.88673
    # starting EURGBP cannot be below strike rate (0.8285) due to knock out condition
    drift = inputs['drift']
    maturity = inputs['maturity']
    t_steps = inputs['t_steps'] # number of working days between 29/12/2017 and 08/03/2018
    trials = inputs['trials']
    xt = float(maturity) / t_steps

    ''' Calibrated Parameters'''
    sigma1 = inputs['sigma1'] # calibration value: 0.0808844481978   Vega01 value: 0.081697724461
    ro = inputs['ro'] # calibration value: 0.000038413221829   Vega01 value: 0.0000387714624899
    v = inputs['v'] #   calibration value: 0.00154807378604    Vega01 value: 0.00153409902822
    
    ''' Contract Structure Info'''
    warrantsNo = inputs['warrantsNo']
    notionalPerWarr = inputs['notionalPerWarr']
    strike = inputs['strike']
    
    ''' Monte Carlo Model'''
    Simulation = mc_simulation(fx1, sigma1, drift, v, ro, maturity, t_steps, trials)  # calling the MC function
    #print(Simulation)
    
    '''
    ============================================
           Storing Monte Carlo Model Outputs
    ============================================
    '''
    sim = np.transpose(Simulation[0])  # creating object to store FX paths
    workingDays = range(t_steps+1)  # creating range for working days
    simFx = pd.DataFrame(sim, columns=workingDays)  # creating table with FX paths in rows and dt as column names
    
    # np.savetxt("EY_ID_24_EURGBP_Sim.csv", np.asarray(simFx), delimiter=",", header=str(workingDays))
    # saving in physical file
    #print('sim FX')
    #print(simFx)
    
    '''
    ============================================
                Cash Settlement Amount
    ============================================
    '''
    # taking last simulated EURGBP value
    settlementRate = simFx[t_steps]
    cashSetAm = np.zeros(trials)
    
    #print('settlement FX rate')
    #print(settlementRate)

    #print("warrantsNo %d notionalPerWarr %f strike %f trials %d" % (warrantsNo,notionalPerWarr,strike,trials))
    #x = warrantsNo * notionalPerWarr * max(0, (settlementRate[0] / strike) - 1) * (1 / settlementRate[0])
    for i in range(trials):
        cashSetAm[i] = warrantsNo * notionalPerWarr * max(0, (settlementRate[i] / strike) - 1) * (1 / settlementRate[i])
    #print('cash settlement amount')
    #print(cashSetAm)
    
    '''
    ============================================
                Continuous Knock Out
    ============================================
    '''
    knockOut = np.zeros((trials, t_steps+1))
    simFx = np.array(simFx)
    
    # print knockOut
    # print simFx
    
    for i in range(trials):
        for j in range(t_steps + 1):
            # it start from 1st column in order not to compare EURGBP value on valuation date
            if simFx[i, j] - strike < 0:
                knockOut[i, j] = 1
                # if any EURGBP value in a single path is lower or equal that strike set value to zero
            if simFx[i, j] - strike > 0:
                knockOut[i, j] = 0
                # if all EURGBP values in a single path are a greater than strike set value to 1
    # print 'knock out'
    # print knockOut
    
    knockOutSum = np.sum(knockOut, axis=1)
    # print('knock out sum')
    # print(knockOutSum)
    
    '''
    ============================================
                Net Settlement
    ============================================
    '''
    netSettlement = np.zeros(trials)
    
    for i in range(trials):
        if knockOutSum[i] > 0:
            netSettlement[i] = 0
        else:
            netSettlement[i] = cashSetAm[i] * 1.000799081
    
     #netSettlement netSettlement[i] = (cashSetAm[i] - warrantsPrice) * np.exp(-drift * delta.days / 365)= Cash Settlement(t0) - Warrant Price(t0)
    return [netSettlement.mean(), (time.time() - start_time)]

def risk(parameter, inputs, alpha = 0.01):

    delta = inputs[parameter]*alpha
    inputs[parameter] += delta
    PV_up = price_option(inputs)[0]
    inputs[parameter] -= 2*delta
    PV_down = price_option(inputs)[0]
    inputs[parameter] += delta
    sensi = (PV_up - PV_down)/2/delta/10000
    return sensi
