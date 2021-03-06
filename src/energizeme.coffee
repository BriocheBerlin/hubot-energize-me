# Description
#   Coffee and Energy. No Cigarettes.
#
# Configuration:
#   config.json needs to be set before running.
#
# Commands:
#   hubot (.*)coffee status(.*)               - shows if coffee machine is switched on or off
#   hubot (.*)switch on coffee(.*)            - switches on coffee machine and gives info about power consumption
#   hubot (.*)switch off coffee(.*)           - switches off coffee machine
#   hubot (.*)get schedule for coffee(.*)     - shows schedule for coffee machine
#   hubot (.*)get device info for coffee(.*)  - shows edimax smart plug info
#   hubot (.*)what's brewin(.*)               - shows if coffee machine is making coffee, building up pressure or waiting.
#
# Author:
#   BriocheBerlin <brigitte.markmann@asquera.de>


smartplug = require("edimax-smartplug")
require('dotenv').config path: '../hubot-energize-me/options.env'
options =
  timeout: parseInt(process.env.TIMEOUT, 10)
  name: process.env.NAME
  host: process.env.HOST
  username: process.env.USERNAME
  password: process.env.PASSWORD

x = Date.now()

module.exports = (robot) ->
  robot.respond /(.*)coffee status(.*)/i, (res) ->
    # get switch status
    smartplug.getSwitchState(options).then((state) ->
      switch_state = if state then 'ON' else 'OFF'
      res.send 'Coffee machine is switched ' + switch_state
    ).catch (e) ->
      res.send 'Request failed: ', e

  robot.respond /(.*)switch on coffee(.*)/i, (res) ->
    smartplug.setSwitchState(true, options).catch (e) ->
      res.send 'Request failed: ', e
    # get switch status
    smartplug.getSwitchState(options).then((state) ->
      switch_state = if state then 'ON' else 'OFF'
      res.send 'Coffee machine is switched ' + switch_state
    ).catch (e) ->
      res.send 'Request failed: ', e
    smartplug.getSwitchPower(options).then((power) ->
      current = 'Current switch power ' + JSON.stringify(power) + ' Watts'
      res.send current
    ).catch (e) ->
      res.send 'Request failed: ', e
    smartplug.getSwitchEnergy(options).then((energy) ->
      res.send JSON.stringify(energy)
    ).catch (e) ->
      res.send 'Request failed: ', e
    smartplug.getStatusValues(true, options).then((all) ->
      res.send JSON.stringify(all)
    ).catch (e) ->
      res.send 'Request failed: ', e

  robot.respond /(.*)switch off coffee(.*)/i, (res) ->
    # set switch OFF
    smartplug.setSwitchState(false, options).catch (e) ->
      res.send 'Request failed: ', e
    # get switch status
    smartplug.getSwitchState(options).then((state) ->
      switch_state = if state then 'ON' else 'OFF'
      res.send 'Coffee machine is switched ' + switch_state
    ).catch (e) ->
      res.send 'Request failed: ', e

  robot.respond /(.*)get schedule for coffee(.*)/i, (res) ->
    # get schedule
    smartplug.getSchedule(options).then((state) ->
      schedule = 'Schedule: ' + JSON.stringify(state)
      res.send schedule
    ).catch (e) ->
      res.send 'Request failed: ', e


  robot.respond /(.*)get device info for coffee(.*)/i, (res) ->
    # get device Info
    smartplug.getDeviceInfo(options).then((state) ->
      res.send 'Device Info: ' + JSON.stringify(state)
    ).catch (e) ->
      res.send 'Request failed: ', e

  robot.respond /(.*)what's brewin(.*)/i, (res) ->
    # get switch status
    smartplug.getSwitchState(options).then((state) ->
      if !state then res.send 'Coffee machine is switched OFF'
      else
        smartplug.getSwitchPower(options).then((power) ->
          calm = 1.5
          brewingCoffee = 215
          heatingUp = 1700
          brewingWhileHeating = 1900
          goingOns = switch
            when power >= brewingWhileHeating or (power >= calm and power <= heatingUp) then 'getting those humans caffeinated.'
            when power <= calm then 'ready.'
            when power >= heatingUp then 'feeling pressurized.'
          res.send 'Coffee machine is ' + goingOns
        ).catch (e) ->
          res.send 'Request failed: ', e
    ).catch (e) ->
      res.send 'Request failed: ', e