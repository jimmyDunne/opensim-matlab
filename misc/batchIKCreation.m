[struct root] = xml_read('../Subject03/hpl_03_IK_Setup_Walk_100_01.xml');

struct.IKTool.IKTrialSet.objects.IKTrial.marker_file = 'Walk_100 02.trc';
xml_write('../Subject03/hpl_03_IK_Setup_Walk_100_02.xml',struct,root);