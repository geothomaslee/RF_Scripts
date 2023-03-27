#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Mar 13 21:23:01 2023

@author: tlee

This includes three different methods of plotting by Backazimuth.

Plot_Station_By_BAZ plots by the value for backazimuth and is thus more
representative of the actual data.

Plot_Station_By_False_BAZ spaces all traces equally apart and does not order them
in order of increasing BAZ, and is thus more conceptual, but it avoids readability
issues when BAZ is heavily clustered.

Plot_Station_By_Binned_BAZ is my attempt at the best of both worlds by stacking
traces in bins of a certain azimuth.
By default, the bin size is 30 degrees.
"""

import os
import matplotlib.pyplot as plt
from obspy import read


Real_BAZ = True # Plots the more physically representative BAZ plot if true
False_BAZ = True # Plots the more conceptual BAZ plot if true
Binned_BAZ = True # Plots the binned BAZ plot if true
Show_Figs = True # Displays the figures on screen if true
Save_Figs = False # Saves the figures made by this script if true

"""
This script expects that traces (RFs) all share a common prefix that allows
them to be globbed via Prefix_* and that traces are organized into directories
named after their corresponding station. An example expected data structure:

/home/user/project_RFs/Stations/Station/Event_*.itr

where the Stations directory contains directories named after each station and
Event_ corresponds to the common prefix for all directories you wish to plot.
station_list is a list of the stations you want to plot.

If you want to assume all directories within the Stations folder are stations
that you want to plot, then ruse the following for station_list

station_list = next(os.walk(f'{station_dir)}/.)[1]
"""
station_dir = '/home/tlee/Maule_RFs/Stations'
trace_pref = 'Event_*.itr' # Make sure to specify radial RFs only
station_list = ['W1A']

scale_factor = 24 # Default = 12
starttime = -5 # Time in seconds relative to first peak
endtime= 25 # Time in seconds relative to first peak
phase_shift = 30 # Time of first peak
bin_size = 5 # Bin size for Binned_BAZ

current_dir = os.getcwd()
starttime = starttime + phase_shift
endtime = endtime + phase_shift

remove_list = []
for station in station_list: # This section removes empty directories so they don't break the script later
    current_station_dir = f'{station_dir}/{station}'
    if len(os.listdir(current_station_dir)) == 0:
        remove_list.append(station)

for station in remove_list:
    station_list.remove(station)

def Plot_Station_By_BAZ(input_stream):
    """Plots functions by backazimuth"""
    fig = plt.figure(figsize=[8, 4],
                        dpi=300)
    ax = fig.add_subplot(1, 1, 1)
    for trace in input_stream:
        true_scale_factor = scale_factor / 1.45
        backaz = trace.stats.sac.baz
        times = trace.times()
        data = (trace.data * true_scale_factor) + backaz
        ax.plot(data, times, "k-", linewidth=0.15)
        ax.fill_betweenx(times, data, backaz,
                         where=(trace.data > 0), color='r')
        ax.fill_betweenx(times, data, backaz,
                         where=(trace.data < 0), color='b')

    ax.set_ylim(top=starttime,bottom=endtime)
    ax.set_ylabel('Time (seconds)')
    ax.set_xlim(left=0,right=360)
    ax.set_xlabel('Backazimuth (degrees)')

    return fig

def Plot_Station_By_False_BAZ(input_stream):
    """Plots functions by conceptual backazimuth, with even spacing"""
    false_scale_factor = scale_factor / (360 / len(stream)) * 1.05
    fig = plt.figure(figsize=[8, 4],
                        dpi=300)
    ax = fig.add_subplot(1, 1, 1)
    for i, trace in enumerate(input_stream):
        times = trace.times()
        data = (trace.data * false_scale_factor) + i
        ax.plot(data, times, "k-", linewidth=0.15)
        ax.fill_betweenx(times, data, i,
                         where=(trace.data > 0), color='r')
        ax.fill_betweenx(times, data, i,
                         where=(trace.data < 0), color='b')

    ax.set_ylim(top=starttime,bottom=endtime)
    ax.set_ylabel('Time (seconds)')
    ax.set_xlim(left=0,right=len(stream))

    return fig

def Plot_Stations_By_Binned_BAZ(input_stream):
    """Plots functions by binned backazimuth"""
    stack_stream = stream.copy()
    stack_stream.clear()

    binned_baz_scale_factor = scale_factor * (bin_size) / 6.5
    fig = plt.figure(figsize=[8, 4],
                     dpi=800)
    ax = fig.add_subplot(1, 1, 1)

    bin_bottom = 0
    bin_top = bin_bottom + bin_size

    while bin_top <= (360):
        traces_in_current_bin = []

        for i, trace in enumerate(input_stream):
            backaz = trace.stats.sac.baz

            if bin_bottom <= backaz <= bin_top:
                traces_in_current_bin.append(i)

        for trace in traces_in_current_bin:
            current_trace = input_stream[trace]
            stack_stream.append(current_trace)

        stack_stream = stack_stream.stack()

        for i, trace in enumerate(stack_stream):
            times = trace.times()
            data = (trace.data * binned_baz_scale_factor) + ((bin_bottom + bin_top) / 2)
            ax.plot(data, times, "k-", linewidth=0.15)
            ax.fill_betweenx(times, data, ((bin_bottom + bin_top) / 2),
                             where=(trace.data > 0), color='r')
            ax.fill_betweenx(times, data, ((bin_bottom + bin_top) / 2),
                             where=(trace.data < 0), color='b')

        ax.set_ylim(top=starttime,bottom=endtime)
        ax.set_ylabel('Time (seconds)')
        ax.set_xlim(left=0,right=360)

        stack_stream.clear()
        bin_bottom += bin_size
        bin_top += bin_size

    return fig

def Make_Fig_Dir(input_fig_type):
    """Makes a directory for the figures of a given type"""
    local_current_dir = os.getcwd()
    fig_dir = f'{local_current_dir}/Backazimuth_Figures'
    fig_type_dir = f'{local_current_dir}/Backazimuth_Figures/{input_fig_type}'
    if os.path.isdir(fig_dir) is False:
        os.mkdir(fig_dir)
    if os.path.isdir(fig_type_dir) is False:
        os.mkdir(fig_type_dir)

if Real_BAZ is True:
    for station in station_list:
        station_RFs = f'{station_dir}/{station}/{trace_pref}'
        stream = read(station_RFs)
        figure = Plot_Station_By_BAZ(stream)
        figure.suptitle(f'RFs Plotted By Backazimuth for Station {station}\n{len(stream)} RFs found',
                        fontsize="12")

        if Show_Figs is True:
            figure.show()

        if Save_Figs is True:
            fig_type = 'Real_BAZ'
            Make_Fig_Dir(fig_type)
            fname = f'{current_dir}/Backazimuth_Figures/{fig_type}/{station}.{fig_type}.png'
            figure.savefig(fname=fname, dpi='figure')

if False_BAZ is True:
    for station in station_list:
        station_RFs = f'/home/tlee/Maule_RFs/Stations/{station}/Event_*'
        stream = read(station_RFs)
        figure = Plot_Station_By_False_BAZ(stream)
        figure.suptitle(f'RFs from Station {station} Plotted By Conceptual Backazimuth\n{len(stream)} RFs found',
                        fontsize="12")

        if Show_Figs is True:
            figure.show()

        if Save_Figs is True:
            fig_type = 'False_BAZ'
            Make_Fig_Dir(fig_type)
            fname = f'{current_dir}/Backazimuth_Figures/{fig_type}/{station}.{fig_type}.png'
            figure.savefig(fname=fname, dpi='figure')

if Binned_BAZ is True:
    for station in station_list:
        station_RFs = f'/home/tlee/Maule_RFs/Stations/{station}/Event_*'
        stream = read(station_RFs)
        figure = Plot_Stations_By_Binned_BAZ(stream)
        figure.suptitle(f'RFs Plotted By Binned Backazimuth for Station {station}\n{len(stream)} RFs found in {bin_size} degree bins',
                        fontsize="12")

        if Show_Figs is True:
            figure.show()

        if Save_Figs is True:
            fig_type = 'Binned_BAZ'
            Make_Fig_Dir(fig_type)
            fname = f'{current_dir}/Backazimuth_Figures/{fig_type}/{station}.{fig_type}.png'
            figure.savefig(fname=fname, dpi='figure')

