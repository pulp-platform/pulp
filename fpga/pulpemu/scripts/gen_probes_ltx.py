import yaml

yaml_file = "probes.yaml"
with open(yaml_file, "r") as f:
    yaml_stream = f.read()
yaml_dic = {'dic' : yaml.load(yaml_stream), 'key' : 'yaml_dic'}
ilas = yaml_dic['dic']['ilas']

print """<?xml version="1.0" encoding="UTF-8"?>
<probeData version="1" minor="1">
  <probeset name="EDA_PROBESET" active="true">
"""
for k,ila in enumerate(ilas):
  for i,probe in enumerate(ila['probes']):
    print """    <!-- %s %s -->
    <probe type="ila" busType="net" source="netlist" spec="ILA_V2_RT">
      <probeOptions Id="DebugProbeParams">
        <Option Id="COMPARE_VALUE.0" value="eq%d&apos;hX"/>
        <Option Id="CORE_LOCATION" value="1:%d"/>
        <Option Id="HW_ILA" value="%s"/>
        <Option Id="PROBE_PORT" value="%d"/>
        <Option Id="PROBE_PORT_BITS" value="0"/>
        <Option Id="PROBE_PORT_BIT_COUNT" value="%d"/>
      </probeOptions>
      <nets>""" % (ila['int_name'], probe['name'], probe['bits'], k, ila['name'], i, probe['bits'])
    if probe['bits']==1:
      print """        <net name="%s/%s"/>""" % (ila['int_name'], probe['name'])
    else:
      for j in xrange(probe['bits']-1,-1,-1):
        print """        <net name="%s/%s[%d]"/>""" % (ila['int_name'], probe['name'], j)
    print """      </nets>
    </probe>
"""

print """  </probeset>
</probeData>
"""
