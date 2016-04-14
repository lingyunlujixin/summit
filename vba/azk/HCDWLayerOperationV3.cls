VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "HCDWLayerOperationV3"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'**********************************************************************************************************
'*
'* ��ʱδʹ�ã�δ�������滻��ǰ��LayerOperation
'*
'* ��ָ����sheet������trans������
'*
'* �������У�����������������з�
'*
'* ��
'*
'* �ԡ�����������������������ϵͳ��������
'*
'*   1�� ��һ��Ϊjob�����ڶ���Ϊ������job
'*
'*   2�� ��1��job�������jobʱ��д���б�ʾ
'*
'*   3�� ��excel��ȡ���ݺ󣬽������(json��ʽ)��
'*
'*       # format1
'*       dictMlayer -- {
'*                          "jobs":[
'*
'*                                   { "job"  : "job1", "dep" : [ {"dep":"depjob1" } , { "dep" : "depjob2" }                          ] } ,
'*                                   { "job"  : "job2", "dep" : [ {"dep":"depjob1" } , { "dep" : "depjob2" } , { "dep" : "depjob3" }  ] } ,
'*                                   { "job"  : "job3", "dep: : [ {"dep":"depjob1" }                                                  ] }
'*
'*                                 ]
'*
'*                     }  # �����һ��Dictionary ��key = "jobs"��value = Collection [{key = jobName, value = dep_job_list}] ��
'*
'*       # format2
'*       dictMlayer -- {                                                                                         # ==>> {
'*                           "job1" : [ {"dep":"depjob1" } , { "dep" : "depjob2" }                          ]  , # ==>>    "job1" : [ "dep1",               ] ,
'*                           "job2" : [ {"dep":"depjob1" } , { "dep" : "depjob2" } , { "dep" : "depjob3" }  ]  , # ==>>    "job2" : [ "dep1", "dep2"        ] ,
'*                           "job3" : [ {"dep":"depjob1" }                                                  ]    # ==>>    "job3" : [ "dep1", "dep2", "dep3"]
'*                                                                                                               # ==>> }
'*                     }  # �����һ��Dictionary ��key = job����value = ����������job����Collection��
'*
'*       # format3
'*       dictMlayer -- { "jobs":
'*                        [
'*                           {"job" : "job1" , "desc" : "job1 description" , "dep" : ["dep1", "# dep1-desc"]                                                 },
'*                           {"job" : "job2" , "desc" : "job2 description" , "dep" : ["dep1" ,"# dep1-desc", "dep2",  "# dep2-desc"]                         },
'*                           {"job" : "job3" , "desc" : "job3 description" , "dep" : ["dep1" ,"# dep1-desc" ,"dep2" , "# dep2-desc", "dep3", "# dep3-desc"]  },
'*                           ����
'*                        ]
'*
'*                     }  #
'*
'**********************************************************************************************************

Public hcdw As Object


' ***** ��ʼ�� *****
Public Sub init(ByRef ws As Worksheet)

    Dim cur_sheet As Worksheet
    
    Set cur_sheet = ws
    
    ' ��������
    Dim i As Integer, j As Integer, k As Integer
    
    Dim obj As Variant, dep As Variant, desc As Variant ' ��ʱ��������¼ÿ�ж�ȡ��trans��������trans
    
    Dim c1 As Collection               ' ��Ϊ�ʵ��items����ʹ�õ���ʱ����
    
    Set hcdw = CreateObject("Scripting.Dictionary")
    
    i = 2
    
    j = i - 2
    
    Do While cur_sheet.Cells(i, 1) <> ""
        
            obj = cur_sheet.Cells(i, 1).Value  ' trans����
            dep = cur_sheet.Cells(i, 2).Value  ' ������trans��
            desc = cur_sheet.Cells(i, 3).Value ' �������ƣ�ע�ͣ�
        
        
            If hcdw.Exists(obj) Then
                
                    Set c1 = hcdw.Item(obj)
                    
                    c1.Add (dep)
                    c1.Add ("# " & desc)

                Else
                    Set c1 = New Collection
                    
                    c1.Add (dep)
                    c1.Add ("# " & desc)
                    
                    hcdw.Add obj, c1
                    
            End If

             
            ' ָ����һ�ű�
            i = i + 1
            j = j + 1
                
        Loop
        
        ' MsgBox m0.Count
        
    
End Sub

' ��ӡ���㼶Job���Ƽ���Ӧ������ϵ, json��ʾ�����ס�
Public Function sprintf()

    Dim o, oo, sval, fval
    
    For Each o In hcdw.Keys

        sval = "["
        For Each oo In hcdw.Item(o)
            sval = sval & quota(oo) & ","
        Next
        
        sval = trimComma(CStr(sval), tcRIGHT) & "]"
    
        fval = fval & Chr(9) & quota(o) & " : " & sval & Chr(13)
    Next
    
    sprintf = "{ " & Chr(13) & fval & " }"

End Function
