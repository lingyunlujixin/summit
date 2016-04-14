VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "AdjaListProcessor"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'********************************************************************************************
'*
'*'''''' ���������Σ�START -> START_PL -> TRANS_1_PL_S_XXX -> END���ķ�ʽ��
'*
'*'''''' ʹ��ָ����Sheet��������һ���ڽӱ�
'*
'* ʹ��ǰ����Ҫ < �� Ϊ �� �� > �ı�����
'*
'*                             1) ��ǰ��ȡ��sheet������CURR_SHEET_IDX����Ĭ�ϣ�9��  ��
'*
'*                             2) ʼ�ڵ�����λ�ã�ͷ�ڵ㼴START��POSITION_ROW��POSITION_COL����Ĭ�ϣ�2,1����
'*
'*                             3) ����������Ҫ���ҵ�Ԫ���Ѵ��ڡ������������ж��Ƿ����ѭ��������CIRCLE_JUDGE_MAX����Ĭ�ϣ�100 * 50���� ����Ҫ��ɾ����
'*
'*                             4) ʹ��{level�ж�}���ܿ��أ�SWITCH����Ĭ�ϣ���������
'*
'* Mod By Lujx 2015/12/28
'*
'********************************************************************************************
'
'
'
' �洢�ڽ�ͼʹ�õ�Dictionary
'
'-------------------------------------------------------------------
'|                ADJACENCY - LIST DICTIONARY                      |
'------------------------------------------------------------------|
'|      KEY   |      VALUE                                         |
'|------------|----------------------------------------------------|
'|     Node1  |      Sub_Dict1<                                    |
'|            |                down_stream_job1 , VISITED_FLAG     |
'|            |                down_stream_job2 , VISITED_FLAG     |
'|            |               >                                    |
'|------------|----------------------------------------------------|
'|     Node2  |      Sub_Dict2<                                    |
'|            |                down_stream_job3 , VISITED_FLAG     |
'|            |                down_stream_job4 , VISITED_FLAG     |
'|            |               >                                    |
'|------------|----------------------------------------------------|
'|     Node3  |      Sub_Dict3<                                    |
'|            |                down_stream_job5 , VISITED_FLAG     |
'|            |                down_stream_job6 , VISITED_FLAG     |
'|            |               >                                    |
'|------------|----------------------------------------------------|
'
Public dict As Object


'
' �洢�ڵ����ڲ㼶����ȣ���һ���ڵ���������ڶ�����
'
'-------------------------------------------------------------------
'|                    JOBS - LEVEL DICTIONARY                      |
'------------------------------------------------------------------|
'|      KEY   |      VALUE                                         |
'|------------|----------------------------------------------------|
'|     Node1  |        2/3/4/5                                     |
'|------------|----------------------------------------------------|
'|     Node2  |        5                                           |
'|------------|----------------------------------------------------|
'|     Node3  |        6/7                                         |
'|------------|----------------------------------------------------|
'
Public levelDict As Object

    ' ���Ϊ�ѳ��У�ͬʱ��¼�ڵ���ʴ�����
Public outQ As Object

    ' ���ڶ����л��Ѵ������ѷ�����У�
Public inQ As Object

Public dhead As String

'''
Private Const CURR_SHEET_IDX = 3 '18

Private Const POSITION_ROW = 181 '2

Private Const POSITION_COL = 1

' ʹ�õĶ���
Private queue As Collection


' ��ʼ��
Private Sub Class_Initialize()

    If outQ Is Nothing Then
    
        Set outQ = CreateObject("Scripting.Dictionary")
        
    End If
    
    If outQ Is Nothing Then
    
        Set outQ = CreateObject("Scripting.Dictionary")
    
    End If
    
    Set queue = New Collection
    
End Sub

' *********************************************
' *
' * ʹ�á�������ӡ���������
' *
' * Ҳ��ʹ�á����Ƴ��ӡ��Ĵ�������ʵ�֣�������
' *
' *********************************************
Public Sub process(target As Worksheet, r As Integer, c As Integer)
    
    Dim tmpColl As Collection
    
    Dim cur_sheet As Worksheet
    
    Dim last As String
        
    Dim start As String
    
    ' ���Դ洢��last������Ľڵ㣨adjacency list node������Ӧ�㼶��level������ʱ����
    Dim node As String, level As Byte
    
    Dim o As Variant, stdo As String
    
    Set cur_sheet = target
    
    ' ��ȡ��ͷ�ڵ㣺һ���ǵڶ��е�һ���ڵ㣬��START
    start = cur_sheet.Cells(r, c)
    'start = "TRANS_4_S_PL_CRM_OVERDUE_DK_H"
    
    dhead = start
    
    ' �Ȱ�start���뵽����
    queue.Add stdNode(start, 1, COMMA)  ' FORMAT => "Trans,1"
    
    ' ���롸����ӡ�
    putInQ stdNode(start, 1, COMMA)
    
    ' ��������
    Do While queue.Count > 0
    
                '' just for debug
                printseq = ""
                
                For Each e In queue
                    printseq = printseq & " [ " & e & " ] "
                Next e
                '' debug ok
                
                Logger.LogDebug CStr(printseq)
                
                ' ȡ����ɾ�����һ��Ԫ��
                last = queue.Item(1)
                queue.Remove (1)
                
                node = Split(last, COMMA)(0)
                level = CByte(Split(last, COMMA)(1))
      
                ' �ҳ�last�ڵ��Ӧ�����νڵ�
                Set tmpColl = findDeped(node, cur_sheet)
                
                ' �������νڵ㣬������н��д���
                For Each o In tmpColl
                
                    stdo = stdNode(o, level + 1, COMMA)
                    
                    ' ����inQʱ�ż�����У����ظ�������У�ȷ��Ч��
                    If Not inQ.Exists(stdo) Then
                    
                        ' ������У�ͬʱ���롸����ӡ����ϣ����Ϊ�����
                        queue.Add stdo
                        putInQ stdo
                        
                    End If
                    
                    ' �����ڽӱ�
                    addToDict node, CStr(o)
            
                Next
                
                ' �Ҳ�����������ʱ��ͨ�ô���������ڵ㣬��������Ϊ�ն��󣨲ο�addtodict��
                If tmpColl.Count = 0 Then
                        addToDict node, Empty
                End If
                    
                
                ' ���²㼶
                addLevelToDict node, level
                
                ' ���ڵ���Ϊ�ѷ��ʣ������½ڵ���ʴ��� + 1
                putOutQ stdNode(node, level, COMMA)

    Loop
        
End Sub

' ��Ԫ�����ӵ��ڽӱ� = �ȴ淵��true, ���ӳɹ�����false����
Private Function addToDict(k As String, v As String) As Boolean

        Dim subdict As Object
        
        Dim exist As Boolean
        
        exist = False
        
        If dict Is Nothing Then
        
            Set dict = CreateObject("Scripting.Dictionary")
        
        End If
        
        If Not dict.Exists(k) Then
        
            Set subdict = CreateObject("Scripting.Dictionary")
            
            If v <> Empty Then
                subdict.Add v, BLANK
            End If
            
            dict.Add k, subdict
            
        Else
        
             Set subdict = dict.Item(k)
             
             If Not subdict.Exists(v) Then
                
                If v <> Empty Then
                    subdict.Add v, BLANK
                End If
                
             Else
             
                exist = True
                
             End If

        End If
        
        addToDict = exist
        
End Function

' ���뵽�㼶�����ز���ʱ�ڵ��Ƿ��Ѵ���
Private Function addLevelToDict(k As String, l As Byte) As Boolean
        
        Dim exist As Boolean
        
        exist = False
        
        ' �洢�㼶
        If levelDict Is Nothing Then
        
            Set levelDict = CreateObject("Scripting.Dictionary")
        
        End If
        
        If Not levelDict.Exists(k) Then

            ' �㼶���뵽levelDict
            levelDict.Add k, l
            
        Else
        
            exist = True
        
             '''''' add level start ''''''
             Dim values() As String
             Dim concat As Boolean
             
             values = Split(levelDict.Item(k), "/")
             concat = True
            
             For Each o In values
                If o = l Then
                    concat = False
                    Exit For
                End If
             Next
            
             If concat Then
             
                levelDict.Item(k) = levelDict.Item(k) & "/" & l
             
              End If
              '''''' add level end ''''''

        End If
        
        addLevelToDict = exist
        
End Function

' ���½ڵ���ʴ��� + 1
' ���ص�ǰ���ʴ���
Private Function putOutQ(ByVal k As String) As Integer
    
    If Not outQ.Exists(k) Then
        outQ.Add k, 1
        
    Else
    
        ' ���ʴ��� + 1
        outQ.Item(k) = outQ.Item(k) + 1
    
    End If
    
    putOutQ = CInt(outQ.Item(k))
    
End Function


' ���롸����ӡ�����
Private Function putInQ(ByVal k As String) As Integer
    
    If inQ Is Nothing Then
    
        Set inQ = CreateObject("Scripting.Dictionary")
    
    End If
    
    If Not inQ.Exists(k) Then
        inQ.Add k, 1
        
    Else
    
        ' ���ʴ��� + 1
        inQ.Item(k) = inQ.Item(k) + 1
    
    End If
    
    putInQ = CInt(inQ.Item(k))
    
End Function



Public Function head() As String

 head = dhead ' Worksheets(CURR_SHEET_IDX).Cells(POSITION_ROW, POSITION_COL)
 
End Function

Public Function rear() As Collection

    Dim endnodes As New Collection
    Dim o1, o2
    
    For Each o1 In dict.Keys
    
        For Each o2 In dict.Item(o1).Keys
            
            If Not dict.Exists(o2) Then
                 endnodes.Add o2
            End If
        Next
        
    Next
    
    Set rear = endnodes

End Function

' ���ؽڵ�����
Public Function Count() As Integer

    Count = dict.Count
    
End Function

' ����Ԫ��
Public Function elements() As Collection

    Dim res As New Collection
    
    Dim pos As Integer, addflg As Boolean
    

    ' ð�ݷ����� �� -> С ��
    For Each o In dict.Keys
    
        pos = 1
        addflg = True
        
        
        For Each io In res
        
            If o > io Then
            
                           
             res.Add o, , pos
            
             addflg = False
             
            Exit For

            Else
                pos = pos + 1
            End If

        Next
        
        If addflg Then
            res.Add o
        End If
        

        Set elements = res
        
    Next

End Function

' breath first search traversal
Public Function BFS() As Collection

    Set BFS = CommonUtil.BFS(dict, head)
    
End Function

' print bfs detail
Public Sub printBFS()

        Dim resultset As Collection
    
        Set resultset = BFS
    
        For Each o In resultset
        
            'Debug.Print o
            Logger.LogTrace " - " & " - " & o
        Next
End Sub

' print dict detail
Public Sub printDict()

        For Each ko In dict.Keys()
        
            'Debug.Print " [  -k-  ] " & ko
            Logger.LogTrace " - " & " - [  -k-  ] " & ko
            For Each vo In dict.Item(ko).Keys()
                
                'Debug.Print " [ --v-- ] " & vo
                Logger.LogTrace " - " & " - [ --v-- ] " & vo
            Next

    Next
End Sub


Public Sub printLEVEL()

    For Each o In levelDict.Keys
    
        Logger.LogInfo " [ " & o & " >>> " & levelDict.Item(o) & " ] "
        
    Next
End Sub

Public Sub printAccessTimes()

    For Each o In outQ.Keys
    
        Logger.LogDebug " [ " & o & " >>> " & outQ.Item(o) & " ] "
        
    Next
End Sub


' ʹ�þ����ӡͼ��
Public Sub printf_DIAGRAM_MATRIX()


End Sub

' ��ӡ���ղ�ͬlevel��depth��ȣ�����Ľ��
Public Sub print_LEVEL_DIMENSION()

    Dim levelDIM As Object
    Dim levelNDS As Collection
    
    ' ���󳤿� = ���������� = ���㼶���� ���Ԫ����
    Dim mLength As Byte, mWidth As Byte
    
    Dim lens As Byte ' ȡ����ڵ��Ӧ�ĳ���
    
    Set levelDIM = CreateObject("Scripting.Dictionary")
    
    For Each o In levelDict.Keys
        
        Dim values() As String, maxv As Integer
        
        values = Split(levelDict.Item(o), "/")
        
        ' ĳЩ����£����һ��ֵ���������ֵ��ȡ�ü���ͷ���ʱ������ʱҪ�ж�ȡ�����ֵ����
        ' 2016/01/11 lujx
        'maxv = values(UBound(values))
        maxv = CommonUtil.maxLevel(CStr(levelDict.Item(o)))
        
        If Not levelDIM.Exists(maxv) Then
                    
            Set levelNDS = New Collection
            levelNDS.Add o
            levelDIM.Add maxv, levelNDS
            
        Else
        
            levelDIM.Item(maxv).Add o
            
        End If
        
        ' �ҳ���󳤶���Ϊ����ĳ������level��
        If CByte(maxv) > mLength Then
            mLength = CByte(maxv)
        End If
        
        ' �ҳ���������Ϊ����Ŀ���job����level��Ӧ��job������
        If CByte(levelDIM(maxv).Count) > mWidth Then
            mWidth = CByte(levelDIM(maxv).Count)
        End If
        
        ' ȡ�õ��ڵ���ĳ���
        If Len(o) > lens Then
            lens = Len(o)
        End If

    Next
    
    ' ---------------------------------------------------------------------
    '
    ' Ų�����棬����code
    ' For Each o In levelDIM.Keys
    
        ' ͳ��ĳlevel��job����������
    '     mCounter = 0
    '     For Each v In levelDIM.Item(o)
    '         Logger.LogInfo CStr(v), CStr(o)
    '         mCounter = mCounter + 1
    '     Next v
        
        ' �ҳ���������Ϊ����Ŀ���job����level��Ӧ��job������
    '     If CByte(mCounter) > mWidth Then
    '         mWidth = CByte(mCounter)
    '     End If

        ' �ҳ���󳤶���Ϊ����ĳ������level��
    '     If CByte(o) > mLength Then
    '         mLength = CByte(o)
    '     End If
    ' Next o
    '
    ' ------------------------------------------------------------------------
    
    ' ��ӡ������ * �У�
    Dim r As Byte, c As Byte, rowstr
    
    ' lens = getNodeMaxLen() + 2
    lens = lens + 2 ' ȷ�����ȸ���
    
    For r = 1 To mWidth Step 1 ' ����
        rowstr = Empty
        For c = 1 To mLength Step 1
            If levelDIM(c).Count >= r Then
                 rowstr = rowstr & rpad(CStr(levelDIM(c)(r)), SPACE, lens)
            Else
                 rowstr = rowstr & rpad(SPACE, SPACE, lens)
            End If
        Next c
        Logger.LogInfo CStr(rowstr)
        'Logger.LogInfo CStr(WorksheetFunction.Rept("-", lens * mLength))
    Next r
    
End Sub


' Ԫ���Ƿ����ڶ�β
Private Function isRear(e As String, l As Byte) As Boolean

    ' �ն���
    If queue.Count = 0 Then
    
        isRear = False
    
    Else
    
       ' isRear = (e = Trim(Split(queue.Item(queue.Count), ",")(0)) And l = CByte(Trim(Split(queue.Item(queue.Count), ",")(1))))
        
         isRear = (e = Trim(Split(queue.Item(queue.Count), ",")(0)))
        
    End If
    

End Function

' ���ڵ�n�Ͳ㼶l����ȣ�ʹ��delim��� ==> "START,1"
Private Function stdNode(n As Variant, l As Byte, delim As String) As String

    stdNode = n & delim & CStr(l)
    
End Function

' ���ؽڵ���󳤶ȣ����ڴ�ӡ���
Private Function getNodeMaxLen() As Byte

    Dim r_max As Byte
    
    For Each e In dict
        If r_max < Len(e) Then
            r_max = Len(e)
        End If
    Next e
    
    getNodeMaxLen = r_max
    
End Function

' destroy
Private Sub Class_Terminate()

End Sub


