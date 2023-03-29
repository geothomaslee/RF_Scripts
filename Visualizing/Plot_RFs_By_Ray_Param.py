#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Mar 13 21:23:01 2023

@author: tlee

This includes three different methods of plotting receiver functions by their
ray parameters, primarily for distinguising multiples vs. real features.

Plot_By_Ray_Parameter plots traces according to their real ray parameter.

Plot_By_Ordered_Ray_Parameter plots traces in order of increasing ray parameter,
but spaces them all equally so it may be easier to read. This is less physically
accurate, but may help visualize certain features conceptually.

Plot_By_Binned_Ray_Parameter plots similarly to the base Plot_By_Ray_Parameter
function, but stacks traces in bins to help read dense clusters of RFs with
similar ray parameters.
"""

import os
import matplotlib.pyplot as plt
from obspy import read
from obspy.taup import TauPyModel

Real_RP = True
Ordered_RP = False
Binned_RP = True
Show_Figs = True # Shows figures if True
Save_Figs = True # Saves the figures made by this script if True

"""
This script expects that traces (RFs) all share a common prefix that allows
them to be globbed via Prefix_* and that traces are organized into directories
named after their corresponding station. An example expected data structure:

/home/user/project_RFs/Stations/Station/Event_*

where the Stations directory contains directories named after each station and
Event_ corresponds to the common prefix for all directories you wish to plot.
station_list is a list of the stations you want to plot.

NOTE: If your station directory contains both radial and receiver functions,
make sure to specify the file extension for whichever type you wish to plot,
as by default both will be pulled if they share the same file name prefix.

Example trace_pref: "Event_*.itr" where .itr is the file extension for radial
receiver functions.

If you want to assume all directories within the Stations folder are stations
that you want to plot, then ruse the following for station_list

station_list = next(os.walk(f'{station_dir)}/.)[1]
"""

station_dir = '/home/tlee/Maule_RFs/Stations'
trace_pref = 'Event_*.itr' # Make sure to specifiy file extension.
station_list = ['W1A']

scale_factor = 2 # Default = 2
starttime = -2 # Time in seconds relative to first peak
endtime= 10 # Time in seconds relative to first peak
phase_shift = 30 # Time of true P-peak. Should be equal for all RFs
bins = 20 # Specifies the number of bins for the binned ray parameter plot.

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

def Plot_By_Ray_Parameter(input_stream,input_model ='iasp91'):
    """Plots receiver functions by their ray parameter calculated using TauP.

    Parameters
    ----------
    input_stream : obspy.core.stream.Stream
        An obspy stream object containing one or more trace objects.
    input_model : string
        Reference earth velocity model. Available models can be found in the
        TauP documentation. The default is 'iasp91'.

    Returns
    -------
    fig : matplotlib.figure
        Returns a matplotlib figure that plots the traces contained within
        the input stream according to the

    """
    fig = plt.figure(figsize=[8, 4],
                        dpi=300)
    ax = fig.add_subplot(1, 1, 1)

    taupmodel = TauPyModel(model=input_model)

    ray_param_list = []
    for trace in input_stream:
        true_scale_factor = scale_factor / 10

        dist = trace.stats.sac.gcarc
        depth = trace.stats.sac.evdp

        p_arrival = taupmodel.get_travel_times(source_depth_in_km=depth,
                                                distance_in_degree=dist,
                                                phase_list=['P'])[0]
        ray_param = p_arrival.ray_param_sec_degree
        ray_param_list.append(ray_param)

        times = trace.times()
        data = (trace.data * true_scale_factor) + ray_param
        ax.plot(data, times, "k-", linewidth=0.15)
        ax.fill_betweenx(times, data, ray_param,
                         where=(trace.data > 0), color='r')
        ax.fill_betweenx(times, data, ray_param,
                         where=(trace.data < 0), color='b')

    ray_param_range = (max(ray_param_list) - min(ray_param_list)) * 0.1
    min_ray_param = min(ray_param_list) - ray_param_range
    max_ray_param = max(ray_param_list) + ray_param_range

    ax.set_ylim(top=starttime,bottom=endtime)
    ax.set_ylabel('Time (seconds)')
    ax.set_xlim(left=min_ray_param,right=max_ray_param)
    ax.set_xlabel('Ray Parameter (seconds/degrees)')

    return fig


def Plot_By_Ordered_Ray_Parameter(input_stream,input_model='iasp91'):
    """Plots receiver functions in order of increasing ray parameter

    This plots the traces with a fixed separation rather than by the difference
    between the ray parameters of subsequent traces. This type of plot is meant
    to highlight features between RFs with different ray parameters that may
    be hard to see in the basic ray parameter plot due to clustering, but
    should not be thought of as "physically" accurate and appropriate for any
    kind of actual calculations.

    Parameters
    ----------
    input_stream : obspy.core.stream.Stream
        An obspy stream object containing one or more trace objects.
    input_model : string
        Reference earth velocity model. Available models can be found in the
        TauP documentation. The default is 'iasp91'.

    Returns
    -------
    fig : matplotlib.figure
        Returns a matplotlib figure that plots the traces contained within
        the input stream according to the

    """
    taupmodel = TauPyModel(model=input_model)
    ray_param_dict = {}

    for i, trace in enumerate(input_stream):
        dist = trace.stats.sac.gcarc
        depth = trace.stats.sac.evdp
        p_arrival = taupmodel.get_travel_times(source_depth_in_km=depth,
                                                distance_in_degree=dist,
                                                phase_list=['P'])[0]
        ray_param = p_arrival.ray_param_sec_degree
        ray_param_dict[i] = ray_param

    sorted_ray_params = sorted(ray_param_dict.items(), key=lambda x:x[1])
    ray_param_dict = dict(sorted_ray_params)

    fig = plt.figure(figsize=[8, 4],
                        dpi=300)
    ax = fig.add_subplot(1, 1, 1)

    ray_param_list = []
    true_scale_factor = scale_factor

    for key in ray_param_dict:
        trace = input_stream[key]

        dist = trace.stats.sac.gcarc
        depth = trace.stats.sac.evdp
        p_arrival = taupmodel.get_travel_times(source_depth_in_km=depth,
                                                distance_in_degree=dist,
                                                phase_list=['P'])[0]
        ray_param = p_arrival.ray_param_sec_degree
        ray_param_list.append(ray_param)

        times = trace.times()
        data = (trace.data * true_scale_factor) + key
        ax.plot(data, times, "k-", linewidth=0.15)
        ax.fill_betweenx(times, data, key,
                         where=(trace.data > 0), color='r')
        ax.fill_betweenx(times, data, key,
                         where=(trace.data < 0), color='b')

    ax.set_ylim(top=starttime,bottom=endtime)
    ax.set_ylabel('Time (seconds)')
    ax.set_xlim(left=-1,right=(len(ray_param_list) + 1))
    ax.set_xlabel('Trace Number')

    return fig


def Plot_By_Binned_Ray_Parameter(input_stream, input_model ='iasp91'):
    """Bins receiver functions by ray parameter and plots the stacks per bin

    Similar to the basic ray parameter plotting function but bins them to
    help see through heavily clustered groups. Bin size cannot be specified,
    but is calculated using a specified number of bins. This seems to be the
    easier approach given the long decimal nature of ray parameters.

    Parameters
    ----------
    input_stream : obspy.core.stream.Stream
        An obspy stream object containing one or more trace objects.
    input_model : string
        Reference earth velocity model. Available models can be found in the
        TauP documentation. The default is 'iasp91'.

    Returns
    -------
    fig : matplotlib.figure
        Returns a matplotlib figure that plots the traces contained within
        the input stream according to the

    """
    stack_stream = stream.copy()
    stack_stream.clear()

    binned_rp_scale_factor = scale_factor * 2 / bins
    fig = plt.figure(figsize=[8, 4],
                     dpi=800)
    ax = fig.add_subplot(1, 1, 1)

    taupmodel = TauPyModel(model=input_model)
    ray_param_list = []

    for i, trace in enumerate(input_stream):
        dist = trace.stats.sac.gcarc
        depth = trace.stats.sac.evdp
        p_arrival = taupmodel.get_travel_times(source_depth_in_km=depth,
                                                distance_in_degree=dist,
                                                phase_list=['P'])[0]
        ray_param = p_arrival.ray_param_sec_degree
        ray_param_list.append(ray_param)

    bin_size = (max(ray_param_list) - min(ray_param_list)) / bins
    bin_bottom = min(ray_param_list)
    bin_top = bin_bottom + bin_size

    xmin = min(ray_param_list) - bin_size
    xmax = max(ray_param_list) + bin_size


    while bin_top <= (max(ray_param_list) + bin_size):
        traces_in_current_bin = []

        for i, trace in enumerate(input_stream):
            dist = trace.stats.sac.gcarc
            depth = trace.stats.sac.evdp
            p_arrival = taupmodel.get_travel_times(source_depth_in_km=depth,
                                                    distance_in_degree=dist,
                                                    phase_list=['P'])[0]
            ray_param = p_arrival.ray_param_sec_degree
            if bin_bottom <= ray_param < bin_top:
                traces_in_current_bin.append(i)
        print(f'Traces that fit in the current bin are {traces_in_current_bin}')

        for trace in traces_in_current_bin:
            current_trace = input_stream[trace]
            stack_stream.append(current_trace)

        stack_stream = stack_stream.stack()

        bin_center = ((bin_top + bin_bottom) / 2)

        for i, trace in enumerate(stack_stream):

            times = trace.times()
            data = (trace.data * binned_rp_scale_factor) + bin_center
            ax.plot(data, times, "k-", linewidth=0.15)
            ax.fill_betweenx(times, data, bin_center,
                             where=(trace.data > 0), color='r')
            ax.fill_betweenx(times, data, bin_center,
                             where=(trace.data < 0), color='b')

        ax.set_ylim(top=starttime,bottom=endtime)
        ax.set_ylabel('Time (seconds)')
        ax.set_xlim(left=xmin,right=xmax)
        ax.set_xlabel('Ray Parameter (seconds/degrees)')

        stack_stream.clear()
        bin_bottom += bin_size
        bin_top += bin_size

    return fig


def Make_Fig_Dir(input_fig_type):
    """Makes a directory for the figures of a given type

    Parameters
    ----------
    input_fig_type : string
        A string that names the type of figure(s) being created.
    input_model : string
        Reference earth velocity model. Available models can be found in the
        TauP documentation. The default is 'iasp91'.
    """
    local_current_dir = os.getcwd()
    fig_dir = f'{local_current_dir}/Ray_Param_Figures'
    fig_type_dir = f'{local_current_dir}/Ray_Param_Figures/{input_fig_type}'
    if os.path.isdir(fig_dir) is False:
        os.mkdir(fig_dir)
    if os.path.isdir(fig_type_dir) is False:
        os.mkdir(fig_type_dir)


if Real_RP is True:
    for station in station_list:
        station_RFs = f'{station_dir}/{station}/{trace_pref}'
        stream = read(station_RFs)
        figure = Plot_By_Ray_Parameter(stream)
        figure.suptitle(f'RFs Plotted By Ray Parameter for Station {station}\n{len(stream)} RFs found',
                        fontsize="12")

    if Show_Figs is True:
        figure.show()

    if Save_Figs is True:
        fig_type = 'Real_RP'
        Make_Fig_Dir(fig_type)
        fname = f'{current_dir}/Ray_Param_Figures/{fig_type}/{station}.{fig_type}.png'
        figure.savefig(fname=fname, dpi='figure')

if Ordered_RP is True:
    for station in station_list:
        station_RFs = f'{station_dir}/{station}/{trace_pref}'
        stream = read(station_RFs)
        figure = Plot_By_Ordered_Ray_Parameter(stream)
        figure.suptitle(f'RFs Plotted In Order of Increasing Ray Parameter for Station {station}\n{len(stream)} RFs found',
                        fontsize="12")

    if Show_Figs is True:
        figure.show()

    if Save_Figs is True:
        fig_type = 'Ordered_RP'
        Make_Fig_Dir(fig_type)
        fname = f'{current_dir}/Ray_Param_Figures/{fig_type}/{station}.{fig_type}.png'
        figure.savefig(fname=fname, dpi='figure')

if Binned_RP is True:
    for station in station_list:
        station_RFs = f'{station_dir}/{station}/{trace_pref}'
        stream = read(station_RFs)
        figure = Plot_By_Binned_Ray_Parameter(stream)
        figure.suptitle(f'RFs Plotted By Binned Ray Parameter for Station {station}\n{len(stream)} RFs found',
                        fontsize="12")

    if Show_Figs is True:
        figure.show()

    if Save_Figs is True:
        fig_type = 'Binned_RP'
        Make_Fig_Dir(fig_type)
        fname = f'{current_dir}/Ray_Param_Figures/{fig_type}/{station}.{fig_type}.png'
        figure.savefig(fname=fname, dpi='figure')


