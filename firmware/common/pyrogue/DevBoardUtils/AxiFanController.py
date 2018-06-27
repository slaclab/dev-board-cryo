#!/usr/bin/env python
#-----------------------------------------------------------------------------
# Title      : PyRogue AXI Fan Controller
#-----------------------------------------------------------------------------
# File       : AxiFanController.py
# Created    : 2018-06-27
#-----------------------------------------------------------------------------
# Description:
# PyRogue AXI Fan Controller for KCU105 dev board
#-----------------------------------------------------------------------------
# This file is part of the rogue software platform. It is subject to
# the license terms in the LICENSE.txt file found in the top-level directory
# of this distribution and at:
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
# No part of the rogue software platform, including this file, may be
# copied, modified, propagated, or distributed except according to the terms
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------


import pyrogue as pr

class AxiFanController(pr.Device):
    def __init__( self, 
            name        = "AxiFanController", 
            description = "AXI fan controller for KCU105", 
            **kwargs):
        super().__init__(name=name, description=description, **kwargs)
        

        self.add(pr.RemoteVariable(
            name        = "TemperatureAdc_",
            description = "Sysmon temperature ADC reading",
            hidden      = True,
            offset      = 0x00,
            bitSize     = 16,
            bitOffset   = 0,
            base        = pr.UInt, 
            mode        = "RO",
            pollInterval = 1,
       ))

        self.add(pr.LinkVariable(
            name        = "Temperature",
            description = "Sysmon temperature ADC reading",
            dependencies = [self.TemperatureAdc_],
            linkedGet    = lambda var: round(var.dependencies[0].value()*502.9098/65536-273.8195, 2),
            typeStr      = "Float64",
       ))

        self.add(pr.RemoteVariable(
            name        = "SysMonAlarm",
            description = "Over-temperature alarm",
            offset      = 0x02,
            bitSize     = 1,
            bitOffset   = 0,
            base        = pr.UInt, 
            mode        = "RO",
       ))

        self.add(pr.RemoteVariable(
            name        = "MultOverrange",
            description = "Multiplier overrange (forces full speed)",
            offset      = 0x02,
            bitSize     = 1,
            bitOffset   = 1,
            base        = pr.UInt, 
            mode        = "RO",
       ))

        self.add(pr.RemoteVariable(
            name        = "Kp",
            description = "Feedback Kp coefficient (0...127)",
            offset      = 0x04,
            bitSize     = 7,
            bitOffset   = 0,
            base        = pr.UInt, 
            mode        = "RW",
       ))

        self.add(pr.RemoteVariable(
            name        = "Preshift",
            description = "Feedback Pre-shift: del =  (T-TargetT) << preshift",
            offset      = 0x05,
            bitSize     = 4,
            bitOffset   = 4,
            base        = pr.UInt, 
            mode        = "RW",
       ))

        self.add(pr.RemoteVariable(
            name        = "RefTempAdc_",
            description = "Feedback Reference Temp. (Equivalent ADC)",
            hidden      = True,
            offset      = 0x06,
            bitSize     = 16,
            bitOffset   = 0,
            base        = pr.UInt, 
            mode        = "RW",
       ))

        self.add(pr.LinkVariable(
            name        = "RefTemperature",
            description = "Feedback Reference Temp. (Equivalent ADC)",
            dependencies = [self.RefTempAdc_],
            linkedGet    = lambda var: round(var.dependencies[0].value()*502.9098/65536-273.8195, 2),
            linkedSet    = lambda var, value, write: var.dependencies[0].set(round((value + 273.8195)*65536/502.9098) , write=write),
            typeStr      = "Float64",
       ))

        self.add(pr.RemoteVariable(
            name        = "Bypass",
            description = "Feedback bypass",
            offset      = 0x04,
            bitSize     = 1,
            bitOffset   = 7,
            base        = pr.UInt, 
            mode        = "RW",
       ))

        self.add(pr.RemoteVariable(
            name        = "Speed",
            description = "Fan speed (0...15) when feedback bypassed",
            offset      = 0x05,
            bitSize     = 4,
            bitOffset   = 0,
            base        = pr.UInt, 
            mode        = "RW",
       ))
