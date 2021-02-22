import voice_robotifier

vrobot = voice_robotifier.VoiceRobotifier()

vrobot.set_voice_name('Harry')
vrobot.set_voice_rate(250) # words per minute

# optional: use different input/output devices than your current default
# vrobot.set_input_device('Microphone (C-Media USB Audio Device)')
# vrobot.set_output_device('CABLE Input (VB-Audio Virtual Cable)')

push_to_talk_key = 'v'
vrobot.start(push_to_talk_key)