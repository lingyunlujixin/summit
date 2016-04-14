VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "SCDProducer"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'*******************************************************************************************************
'*
'* ���ƣ�
'*
'* ���ܣ�
'*
'* ʱ�䣺
'*
'* �޸ļ�¼��
'*
'*******************************************************************************************************

'-------------------------------------------------
'�������滻�б���
'
' �洢Ԥ����ġ�������������Ӧֵ��,���Դ����ϳɵ�
'
' sql�еı���(${VAR})
'-------------------------------------------------
'
' Dict - <"${MY_DT}"        , "'${MY_DT}'"    >
'        <"${MAX_DT}"       , "'${MAX_DT}'"   >
'        <"${V_CAT}"        , "test.vt_xx"    >
'        ........
'
'-------------------------------------------------
  Private varDict As Dictionary

'-------------------------------------------------
' �洢��������Ϣ���������֣�
'
'    --  ����Ϣ����#��ͷ��
'
'    --  �ֶ���Ϣ��
'-------------------------------------------------
'
' Dict - <"#SRC_TABLE_NAME"   , Table_Name  >
'        <"#SRC_TABLE_SCHEMA" , SCHEMA_VAR  >
'        <"#TAR_TABLE_NAME"   , Table_Name  >
'        <"#TAR_TABLE_SCHEMA" , SCHEMA_VAR  >
'        <"#SRC_TABLE"        , SCHEMA.TABLE>
'        <"#TAR_TABLE"        , SCHEMA.TABLE>
'        <FieldName           , FIELD_INFO  >
'        ........
'
'
'-------------------------------------------------
Private tableMetaDataDict As Dictionary

' ��¼�������ֶΣ������������������ֶΣ����ֲ��䣨���£����ֶΣ�
Private tableKeyFileds As Collection
Private tableInsertFileds As Collection
Private tableUpdateFileds As Collection

' ��ʼ��
Private Sub Class_Initialize()
    
    Set tableMetaDataDict = New Dictionary
    
    Set varDict = New Dictionary
    
End Sub

' ��ʼ���������滻�б���
Private Sub preVarDict()
    
    ' Դ��
    varDict.Add "${SRC_TABLE}", tableMetaDataDict(SRC_TABLE)
    varDict.Add "${SRC_TABLE_SCHEMA}", tableMetaDataDict(SRC_TABLE_SCHEMA)
    varDict.Add "${SRC_TABLE_NAME}", tableMetaDataDict(SRC_TABLE_NAME)
    
    ' Ŀ���
    varDict.Add "${TAR_TABLE}", tableMetaDataDict(TAR_TABLE)
    varDict.Add "${TAR_TABLE_SCHEMA}", tableMetaDataDict(TAR_TABLE_SCHEMA)
    varDict.Add "${TAR_TABLE_NAME}", tableMetaDataDict(TAR_TABLE_NAME)
    varDict.Add "${TAR_TABLE_BAK}", tableMetaDataDict(TAR_TABLE) & "_bak"
    
    ' ��ʱ��
    varDict.Add "${V_CAT}", stdVCatTbl(tableMetaDataDict(SRC_TABLE_NAME), tableMetaDataDict(TAR_TABLE_SCHEMA))
    varDict.Add "${V_TAR}", stdVTarTbl(tableMetaDataDict(TAR_TABLE_NAME), tableMetaDataDict(TAR_TABLE_SCHEMA))
    
    ' ������
    varDict.Add "${MAX_DT}", tableMetaDataDict(MAX_DT)
    varDict.Add "${MY_DT}", tableMetaDataDict(MY_DT)
    varDict.Add "${LITERAL_MY_DT}", "${MY_DT}"
     
    ' ����
    varDict.Add "${MYSQL_COMMENT}", "${MYSQL_COMMENT}"
    
    ' Ϊ��Ӧhive
    varDict.Add "/* 'closed' */", rpad(" ", " ", VBA.Len("/* 'closed' */"))
    varDict.Add "/* 'unchanged' */", rpad(" ", " ", VBA.Len("/* 'unchanged' */"))
    varDict.Add "/* 'changed' */", rpad(" ", " ", VBA.Len("/* 'changed' */"))
    varDict.Add "/* 'insert' */", rpad(" ", " ", VBA.Len("/* 'insert' */"))
    
End Sub

' ��ָ����excel�����ʼ����������Ϣ
Public Sub setExcel(target As Worksheet, r As Integer, c As Integer)

    Dim curWkst As Worksheet
    
    Dim irow As Integer
    
    Dim FieldName As String, FieldType As String, FieldOperType As String, FieldComment As String
    
    Dim td As Dictionary
    
    Set curWkst = target
    
    ' ���ӱ���
    'tableMetaDataDict.Add SRC_TABLE_NAME, VBA.Split(curWkst.Name, ",")(0)

    ' ���ӱ���(SRC)
    tableMetaDataDict.Add SRC_TABLE, VBA.Trim(curWkst.Cells(1, 7).Value)
    tableMetaDataDict.Add SRC_TABLE_SCHEMA, VBA.Split(curWkst.Cells(1, 7).Value, ".")(0)
    tableMetaDataDict.Add SRC_TABLE_NAME, VBA.Split(curWkst.Cells(1, 7).Value, ".")(1)

    ' ���ӱ���(TAR)
    tableMetaDataDict.Add TAR_TABLE, VBA.Trim(curWkst.Cells(2, 7).Value)
    tableMetaDataDict.Add TAR_TABLE_SCHEMA, VBA.Split(curWkst.Cells(2, 7).Value, ".")(0)
    tableMetaDataDict.Add TAR_TABLE_NAME, VBA.Split(curWkst.Cells(2, 7).Value, ".")(1)
    
    ' �������ڲ���
    tableMetaDataDict.Add MAX_DT, "cast('" & curWkst.Cells(3, 7).Value & "' as date)"
    tableMetaDataDict.Add MY_DT, "cast('" & curWkst.Cells(4, 7).Value & "' as date)"
    
    ' ��ʼ�������ֵ�
    preVarDict
    
    ' ������ʼ����
    irow = r
    
    ' ����
    Do While curWkst.Cells(irow, c) <> Empty
    
        ' �ֶ�����
        FieldName = VBA.Replace(curWkst.Cells(irow, c), "`", "")
        
        ' �ֶ�����
        FieldType = curWkst.Cells(irow, c + 1)
        
        ' ��������
        FieldOperType = curWkst.Cells(irow, c + 2)
        
        ' ע��
        FieldComment = curWkst.Cells(irow, c + 3)
        
        Set td = New Dictionary
        
        td.Add "FIELD_NAME", FieldName
        td.Add "FIELD_TYPE", VBA.UCase(FieldType)
        td.Add "FIELD_COMMENT", FieldComment
        td.Add "FIELD_OPER_TYPE", VBA.UCase(FieldOperType)
        
        'tableMetaDataDict.Add FieldName, getStates(FieldType, FieldOperType)
        tableMetaDataDict.Add FieldName, td
        
        irow = irow + 1
    Loop
    
    ' debug
    For Each o In tableMetaDataDict.keys
        'Logger.LogDebug CStr(o), CStr(tableMetaDataDict(o))
    Next

End Sub

'  �������е�����
Public Function keySet() As Collection

    If Not tableKeyFileds Is Nothing Then
        Set keySet = tableKeyFileds
        Exit Function
    End If
    
    Dim keys As New Collection
    
    For Each o In tableMetaDataDict.keys
    
        'If (tableMetaDataDict(o) And InterfaceStates.OPER_TYPE_KEY) > 0 Then
        '    keys.Add o
        'End If
        
        
        If VBA.Left(o, 1) <> "#" Then
            If tableMetaDataDict(o)("FIELD_OPER_TYPE") = "KEY" Then
                keys.Add o
            End If
        End If
    Next o
    
    Set tableKeyFileds = keys
    
    Set keySet = tableKeyFileds
    
End Function


'  �������е�Insert�ֶΣ������������ֶΣ�
Public Function insertSet() As Collection

    If Not tableInsertFileds Is Nothing Then
        Set insertSet = tableInsertFileds
        Exit Function
    End If
    
    Dim keys As New Collection
    
    For Each o In tableMetaDataDict.keys
    
        'If (tableMetaDataDict(o) And InterfaceStates.OPER_TYPE_INSERT) > 0 Then
        '    keys.Add o
        'End If
        If VBA.Left(o, 1) <> "#" Then
            If tableMetaDataDict(o)("FIELD_OPER_TYPE") = "INSERT" Then
                keys.Add o
            End If
        End If
        
    Next o
    
    Set tableInsertFileds = keys
    Set insertSet = keys
    
End Function

'  �������е�Update�ֶΣ��������������ֶΣ�
Public Function updateSet() As Collection

    If Not tableUpdateFileds Is Nothing Then
        Set updateSet = tableUpdateFileds
        Exit Function
    End If
    
    Dim keys As New Collection
    
    For Each o In tableMetaDataDict.keys
    
        'If (tableMetaDataDict(o) And InterfaceStates.OPER_TYPE_UPDATE) > 0 Then
        '    keys.Add o
        'End If
        If VBA.Left(o, 1) <> "#" Then
                If tableMetaDataDict(o)("FIELD_OPER_TYPE") = "UPDATE" Then
                    keys.Add o
                End If
        End If
    Next o
    
    Set tableUpdateFileds = keys
    Set updateSet = keys
    
End Function

'  �������е�insert & Update�ֶ�
Public Function upsertSet() As Collection
    
    Dim keys As New Collection
    
    For Each o In tableMetaDataDict.keys
    
        If VBA.Left(o, 1) <> "#" Then
                If tableMetaDataDict(o)("FIELD_OPER_TYPE") <> "KEY" Then
                    keys.Add o
                End If
        End If
    Next o
    
    Set upsertSet = keys
    
End Function


' ������������ʹ�õ�SQL
Public Sub start(FileName As String)

    Dim literal As String
    Dim textCache As New Collection
    
    
    ' 1.01 ���ɴ���Catlog���ṹ��SQL
    literal = genCat_Table()
    Logger.LogDebug literal
    textCache.Add replaceVar(literal)
    
    ' 1.02 ��ʼ��Truncate
    literal = genCat_Clear()
    Logger.LogDebug literal
    textCache.Add replaceVar(literal)
    
    ' 1.03 �ҳ����Ϊinsert�ļ�¼
    literal = genCat_Insert()
    Logger.LogDebug literal
    textCache.Add replaceVar(literal)
    
    ' 1.04 �ҳ����Ϊclosed��changed��unchanged�ļ�¼
    literal = genCat_Closed_Changed_Unchanged()
    Logger.LogDebug literal
    textCache.Add replaceVar(literal)
    
    ' 2.01 ��Insert�ļ�¼����Ŀ�������ʱĿ�����
    literal = genUnion_Insert()
    Logger.LogDebug literal
    textCache.Add replaceVar(literal)
    
    ' 2.02 ����ʷ���ݣ�������������δ�仯�������Ǹ��£�Ҳ������һ���ޱ仯�������ݲ���Ŀ�������ʱĿ�����
    literal = genUnion_His_Closed_Changed_Unchanged()
    Logger.LogDebug literal
    textCache.Add replaceVar(literal)
    
    ' 2.03 ��changed�ļ�¼�������ٴβ���Ŀ�������ʱĿ�����
    literal = genUnion_NewChanged()
    Logger.LogDebug literal
    textCache.Add replaceVar(literal)
    
    ' 2.04 ˢ��Ŀ���~
    literal = getUnion_Target()
    Logger.LogDebug literal
    textCache.Add replaceVar(literal)
    
    ' persist to file
    persistence textCache, FileName
    
    'OK��
    ' ���������ɵ�SQL�Ĵ洢���ļ�����
    
End Sub

'**********************************************************
'*
'* ����ʹ�õ���ʱ��
'*
'* �޸ģ��� ������2016/01/01 by lujx XXX��
'*
'**********************************************************
Private Function genCat_Table() As String

    Dim keyDef As String
    For Each o In keySet()
    
        keyDef = Switch(keyDef = Empty, Empty, keyDef <> Empty, keyDef & vbCrLf) _
                 & formatColumn(CStr(o), CStr(tableMetaDataDict(o)("FIELD_TYPE")) _
                            , False, CStr(tableMetaDataDict(o)("FIELD_COMMENT")), "") _
                 & ","
        
    Next o
    
    genCat_Table = vbCrLf _
                    & WorksheetFunction.Rept("#", 50) _
                    & vbCrLf _
                    & vbCrLf _
                    & "-- SPECIFIC TABLE - CREATION " _
                    & vbCrLf _
                    & "CREATE TABLE    IF NOT EXISTS ${V_CAT} (" _
                    & vbCrLf _
                    & keyDef _
                    & vbCrLf _
                    & formatColumn("typ", "TINYINT", False, "1 - INSERT/2 - CLOSED/3 - UNCHANGED/4 - CHANGED", "-1") & "," _
                    & vbCrLf _
                    & formatColumn("ver", "INT", False, "VERSION NUMBER", "1") & "," & vbCrLf _
                    & formatPrimaryKey(keySet()) & "," _
                    & vbCrLf _
                    & formatKey(keySet()) _
                    & vbCrLf _
                    & " ) ENGINE=INNODB DEFAULT CHARSET=utf8 " _
                    & vbCrLf _
                    & " PARTITION BY HASH(typ) PARTITIONS 4;" _
                    & vbCrLf _
                    & vbCrLf _
                    & "CREATE TABLE IF NOT EXISTS ${V_TAR} LIKE ${TAR_TABLE};" _
                    & vbCrLf & vbCrLf _
                    & WorksheetFunction.Rept("#", 50)

End Function

'**********************************************************
'*
'* �����ʱ���Ѵ��ڣ�ʹ��ǰȷ����ʱ�����
'*
'* �޸ģ��� ������2016/01/01 by lujx XXX��
'*
'**********************************************************
Private Function genCat_Clear() As String

    genCat_Clear = vbCrLf _
                    & "-- Clear temporary table" _
                    & vbCrLf _
                    & "TRUNCATE TABLE ${V_CAT};" _
                    & vbCrLf _
                    & "TRUNCATE TABLE ${V_TAR};"
End Function

'**********************************************************
'*
'* ����׶Σ��ҳ����Ϊinsert���������ļ�¼
'*
'* �޸ģ��� ������2016/01/01 by lujx XXX��
'*
'**********************************************************
Private Function genCat_Insert() As String

    Dim selectKeys As String, joinKeys As String, whereKeys As String
    
    For Each o In keySet()
        selectKeys = Switch(selectKeys = Empty, vbTab & "  a." & o, selectKeys <> Empty, selectKeys & vbCrLf & vbTab & ", a." & o)
        joinKeys = Switch(joinKeys = Empty, "  ON a." & o & " = b." & o, joinKeys <> Empty, joinKeys & vbCrLf & " AND a." & o & " = b." & o)
        whereKeys = "b." & o & " IS NULL"
    Next o
    
    genCat_Insert = vbCrLf & "-- step 01. Pick out records marked 'insert' ( type = 1 )" _
                    & vbCrLf _
                    & "INSERT INTO ${V_CAT} " _
                    & vbCrLf _
                    & "SELECT" _
                    & vbCrLf _
                    & selectKeys _
                    & vbCrLf _
                    & vbTab & ", 1 -- 'insert'" _
                    & vbCrLf _
                    & vbTab & ", 1 -- 'version 1 for insert-record'" _
                    & vbCrLf _
                    & "FROM      ${SRC_TABLE} a" _
                    & vbCrLf _
                    & "LEFT JOIN ${TAR_TABLE} b" _
                    & vbCrLf _
                    & joinKeys _
                    & vbCrLf _
                    & "AND b.start_dt < ${MY_DT}" _
                    & vbCrLf _
                    & "AND b.end_dt  >= ${MY_DT}" _
                    & vbCrLf _
                    & "WHERE " & whereKeys & ";"

End Function

'**********************************************************
'*
'* ����׶Σ��ҳ����Ϊclosed������ɾ������changed��������������unchanged��������������ֻ���£��ļ�¼
'*
'* �޸ģ��� ������2016/01/01 by lujx XXX��
'*
'**********************************************************
Private Function genCat_Closed_Changed_Unchanged() As String

    Dim selectKeys As String, joinKeys As String, whereKeys As String, casewhen_sub As String, casewhen As String
    
    For Each o In keySet()
        selectKeys = Switch(selectKeys = Empty, vbTab & "  b." & o, selectKeys <> Empty, selectKeys & vbCrLf & vbTab & ", b." & o)
        joinKeys = Switch(joinKeys = Empty, "  ON a." & o & " = b." & o, joinKeys <> Empty, joinKeys & vbCrLf & " AND a." & o & " = b." & o)
        whereKeys = "a." & o & " IS NULL"
    Next o
    
    For Each o In insertSet()

        opad = rpad(CStr(o), " ", 30)
        
        If casewhen_sub = Empty Then
            casewhen_sub = vbTab _
                           & "                ((" & rpad("a." & o, " ", 30) & " = " & rpad("b." & o, " ", 30) & " ) OR (a." & opad & " IS NULL AND b." & opad & " IS NULL ))"
        Else
            casewhen_sub = casewhen_sub _
                           & vbCrLf _
                           & vbTab _
                           & "            AND ((" & rpad(CStr(specialTransform("a." & o, True)), " ", 30) & " = " & rpad(coalesce("b." & o), " ", 30) & " ) OR (a." & opad & " IS NULL AND b." & opad & " IS NULL ))"
        End If
    Next o
    
    casewhen = vbTab & ", CASE WHEN " & whereKeys & "                                " _
             & vbCrLf _
             & vbTab & "       THEN 2 -- 'closed'                                    " _
             & vbCrLf _
             & vbTab & "       WHEN                                                  " _
             & vbCrLf _
             & casewhen_sub & "                                              " _
             & vbCrLf _
             & vbTab & "       THEN     3 -- 'unchanged'                             " _
             & vbCrLf _
             & vbTab & "       ELSE     4 -- 'changed'                               " _
             & vbCrLf _
             & vbTab & "   END                                                       "
             
genCat_Closed_Changed_Unchanged = vbCrLf & "-- step 02. Pick out records marked 'closed'   ( type = 2 )" _
                                & vbCrLf _
                                & "--                                  'unchanged'( type = 3 )" _
                                & vbCrLf _
                                & "--                                  'changed'  ( type = 4 )" _
                                & vbCrLf _
                                & "INSERT INTO ${V_CAT} " _
                                & vbCrLf _
                                & "SELECT" _
                                & vbCrLf _
                                & selectKeys _
                                & vbCrLf _
                                & casewhen _
                                & vbCrLf _
                                & vbTab & ", b.version" _
                                & vbCrLf _
                                & "FROM      ${TAR_TABLE} b" _
                                & vbCrLf _
                                & "LEFT JOIN ${SRC_TABLE} a" _
                                & vbCrLf _
                                & joinKeys _
                                & vbCrLf _
                                & "WHERE b.start_dt   <   ${MY_DT} -- fetch his-data !! support reload operation" _
                                & vbCrLf _
                                & "  AND b.end_dt     >=  ${MY_DT} ; -- fetch his-data !! support reload operation"
End Function

'**********************************************************
'*
'* �ϲ��׶Σ��ѱ��Ϊinsert���������ļ�¼����Ŀ���
'*
'* �޸ģ��� ������2016/01/01 by lujx XXX��
'*
'**********************************************************
Private Function genUnion_Insert() As String

    Dim res As String
    Dim selectFields As String, joinKeys As String, insertFields As String
    
    For Each o In keySet()
        joinKeys = Switch(joinKeys = Empty, "  ON a." & o & " = b." & o, joinKeys <> Empty, joinKeys & vbCrLf & " AND a." & o & " = b." & o)
    Next
    
    For Each o In tableMetaDataDict.keys
        If VBA.Left(o, 1) <> "#" Then

            If selectFields = Empty Then
                insertFields = vbTab & "  " & "`" & o & "`"
                selectFields = vbTab & "  " & rpad(CStr("a." & o), " ", 30) & " as `" & o & "`"
            Else
                insertFields = insertFields & vbCrLf & vbTab & ", " & "`" & o & "`"
                selectFields = selectFields & vbCrLf & vbTab & ", " & rpad(CStr(specialTransform("a." & o, True)), " ", 30) & " as `" & o & "`"
            End If
            
        End If
    Next
    
    res = vbCrLf & "-- step 03. reduce result(new target table)       " _
        & vbCrLf _
        & "INSERT INTO ${V_TAR} " _
        & vbCrLf _
        & "(" _
        & vbCrLf _
        & insertFields _
        & vbCrLf _
        & " , version       " _
        & vbCrLf _
        & " , start_dt      " _
        & vbCrLf _
        & " , end_dt        " _
        & vbCrLf _
        & " , load_stamp    " _
        & vbCrLf _
        & ")"
                    
    res = res & vbCrLf _
            & "--  insert (from src) " _
            & vbCrLf _
            & "SELECT" _
            & vbCrLf _
            & selectFields _
            & vbCrLf _
            & "  , 1                           AS version      " _
            & vbCrLf _
            & "  , ${MY_DT}                    AS start_dt     " _
            & vbCrLf _
            & "  , ${MAX_DT}                   AS end_dt       " _
            & vbCrLf _
            & "  , CURRENT_TIMESTAMP                           " _
            & vbCrLf _
            & "FROM       ${SRC_TABLE}                        a" _
            & vbCrLf _
            & "INNER JOIN ${V_CAT}                            b" _
            & vbCrLf _
            & joinKeys _
            & vbCrLf _
            & "  AND b.`typ` = 1 ; -- 'insert'"
            
    genUnion_Insert = res
        
End Function

'**********************************************************
'*
'* �ϲ��׶Σ��ѱ��Ϊ
'*                    �� closed������ɾ����
'*                    �� changed������������
'*                    �� unchanged��������������ֻ���£�
'* �������Լ���
'*                    �� ��ʷ����
'* ����Ŀ���
'*
'* �޸ģ��� ������2016/01/01 by lujx XXX��
'*
'**********************************************************
Private Function genUnion_His_Closed_Changed_Unchanged() As String

    Dim res As String
    Dim selectKeys As String, aJoinBKeys As String, bJoinCKeys As String, whereKeys As String, casewhen_sub As String, casewhen As String
    Dim insertFields As String
    
    For Each o In keySet()
        aJoinBKeys = Switch(aJoinBKeys = Empty, "  ON a." & o & " = b." & o, aJoinBKeys <> Empty, aJoinBKeys & vbCrLf & " AND a." & o & " = b." & o)
        bJoinCKeys = Switch(bJoinCKeys = Empty, "  ON b." & o & " = c." & o, bJoinCKeys <> Empty, bJoinCKeys & vbCrLf & " AND b." & o & " = c." & o)
        selectKeys = Switch(selectKeys = Empty, vbTab & "  a." & rpad(CStr(o), " ", 30) & " AS `" & o & "`", selectKeys <> Empty, selectKeys & vbCrLf & vbTab & ", a." & rpad(CStr(o), " ", 30) & " AS `" & o & "`")
        whereKeys = "b." & o & " IS NULL"
    Next
    
    For Each o In tableMetaDataDict.keys
    
        If VBA.Left(o, 1) <> "#" Then
            
            If insertFields = Empty Then
                insertFields = vbTab & "  `" & o & "`"
            Else
                insertFields = insertFields & vbCrLf & vbTab & ", `" & o & "`"
            End If
            
        End If
    Next
    
    For Each o In upsertSet()
        
        casewhen = casewhen _
                  & vbCrLf & vbTab & ", CASE WHEN " & rpad(whereKeys, " ") & VBA.Trim("                         ") & " THEN a." & o _
                  & vbCrLf & vbTab & "       WHEN " & rpad("b.typ  = 3  /* 'unchanged' */                  ", " ") & " THEN " & specialTransform("c." & o, True) _
                  & vbCrLf & vbTab & "       WHEN " & rpad("b.typ IN ( 2 /* 'closed' */, 4 /* 'changed' */)", " ") & " THEN a." & o _
                  & vbCrLf & vbTab & "  END  AS `" & o & "`"
    Next o
        
   res = vbCrLf & "-- # closed (tar) & changed (tar) & unchanged (src)" _
       & vbCrLf _
       & "INSERT INTO ${V_TAR}" _
       & vbCrLf _
       & "(" _
       & vbCrLf _
       & insertFields _
       & vbCrLf _
       & "   , version    " _
       & vbCrLf _
       & "   , start_dt   " _
       & vbCrLf _
       & "   , end_dt     " _
       & vbCrLf _
       & "   , load_stamp " _
       & vbCrLf _
       & ")" _
       & vbCrLf
       
    res = res _
       & "SELECT" _
       & vbCrLf _
       & selectKeys _
       & casewhen _
       & vbCrLf _
       & vbTab & ", a.version   AS version  " _
       & vbCrLf _
       & vbTab & ", a.start_dt  AS start_dt " _
       & vbCrLf _
       & vbTab & ", CASE WHEN " & rpad(whereKeys, " ") & VBA.Trim("                          ") & " THEN a.end_dt    -- his             " _
       & vbCrLf _
       & vbTab & "       WHEN " & rpad("b.typ = 3 /* 'unchanged' */                     ", " ") & " THEN ${MAX_DT}                    " _
       & vbCrLf _
       & vbTab & "       WHEN " & rpad("b.typ IN ( 2 /* 'closed' */ , 4 /* 'changed' */)", " ") & " THEN ${MY_DT}                     " _
       & vbCrLf _
       & vbTab & "       ELSE cast('0001-01-01' as date) -- never used                                                                " _
       & vbCrLf _
       & vbTab & "   END    As end_dt                                                                                    " _
       & vbCrLf
       
    res = res _
       & "  , a.load_stamp                                                                                        " _
       & vbCrLf _
       & " FROM       ${TAR_TABLE}   a          " _
       & vbCrLf _
       & " LEFT JOIN  ${V_CAT}       b          " _
       & vbCrLf _
       & aJoinBKeys _
       & vbCrLf _
       & "   -- AND b.`typ` IN ('closed', 'changed', 'unchanged')                                                 " _
       & vbCrLf _
       & "  AND a.start_dt < ${MY_DT} -- support reload operation                                               " _
       & vbCrLf _
       & "  AND a.end_dt  >= ${MY_DT} -- support reload operation                                               " _
       & vbCrLf _
       & " LEFT JOIN  ${SRC_TABLE}                                           c         " _
       & vbCrLf _
       & bJoinCKeys _
       & vbCrLf _
       & " WHERE a.start_dt < ${MY_DT}  -- contains his-data && support reload operation " _
       & vbCrLf _
       & ";"
       
       genUnion_His_Closed_Changed_Unchanged = res
       
End Function

'**********************************************************
'*
'* ��changed�ļ�¼�������ٴβ��뵽Ŀ�������ʱĿ�����
'*
'* �޸ģ��� ������2016/01/01 by lujx XXX��
'*
'**********************************************************
Private Function genUnion_NewChanged() As String

    genUnion_NewChanged = vbCrLf & " -- changed(from src)" _
                        & vbCrLf _
                        & formatInsertIntoTar() _
                        & vbCrLf _
                        & formatSelectChanged()

End Function


'**********************************************************
'*
'* ����ʱ��������ˢ�µ�Ŀ�����ͬʱ��Ŀ�������һ�£����Խ׶Σ�
'*
'* �޸ģ��� ������2016/01/01 by lujx XXX��
'*
'**********************************************************
Private Function getUnion_Target() As String

    s = vbCrLf & "-- Just for test - bakup"
    s = s & vbCrLf & "DROP   TABLE IF EXISTS       ${TAR_TABLE_BAK};"
    s = s & vbCrLf & "RENAME TABLE ${TAR_TABLE} TO ${TAR_TABLE_BAK};"  ' "TRUNCATE TABLE ${TAR_TABLE};"
    s = s & vbCrLf & "RENAME TABLE ${V_TAR}     TO ${TAR_TABLE};"
    
    getUnion_Target = s
    
End Function

' ��ʱ��������Ʊ�׼��
Private Function stdVCatTbl(ByVal SrcTbl As String, Optional ByVal Schema As String = "") As String

    Dim v As String
    
    v = "vt_" & SrcTbl & "_catlog"
    
    stdVCatTbl = Switch(Schema = Empty, v, Schema <> Empty, Schema & "." & v)
    
End Function

' ��ʱĿ������Ʊ�׼��
Private Function stdVTarTbl(ByVal TarTbl As String, Optional ByVal Schema As String = "") As String

    Dim v As String
    
    v = "vt_" & TarTbl
    
    stdVTarTbl = Switch(Schema = Empty, v, Schema <> Empty, Schema & "." & v)
    
End Function

' �õ���ʽ������ => ������ʱ��ʱʹ��
Private Function formatColumn(FieldName As String, FieldType As String, Optional NullFlag As Boolean = True, Optional FieldComment As String = "", Optional DefualtValue As String = "")

    'Dim stdLen As Integer
    
    'stdLen = (WorksheetFunction.Floor(VBA.Len(FieldName) / INT_20, 1) + 1) * INT_20
    
    formatColumn = rpad(FieldName, " ", 30) _
                   & rpad(FieldType, " ", 30) _
                   & Switch(NullFlag, rpad(" ", " ", 30), Not NullFlag, rpad("NOT NULL ", " ", 30)) _
                   & Switch(DefualtValue = Empty, rpad(" ", " ", 30), DefualtValue <> Empty, rpad("DEFAULT " & DefualtValue, " ", 30)) _
                   & "COMMENT " _
                   & "'" & FieldComment & "'"

End Function

Public Function formatPrimaryKey(keys As Collection, Optional haveTyp As Boolean = True) As String
    
    Dim v As String
    
    v = "PRIMARY KEY ("
    For Each o In keys
       v = v & o & ","
    Next o
    
    formatPrimaryKey = Switch(haveTyp, v & "typ)", Not haveTyp, VBA.Left(v, VBA.Len(v) - 1) & ")")
    
End Function

Public Function formatKey(keys As Collection) As String
    
    Dim v As String
    
    v = "KEY idx("
    For Each o In keys
       v = v & o & ","
    Next o
    
    formatKey = VBA.Left(v, VBA.Len(v) - 1) & ")"
    
End Function

' ��ʽ���������� =>   on a.col1 = b.col1
'                    and a.col2 = b.col2
Private Function formatJoin(LeftAlias As String, RightAlias As String, cons As Collection)

        Dim joins As String
        
        For Each o In cons
            joins = Switch(joins = Empty, "  ON " & LeftAlias & "." & o & " = " & RightAlias & "." & o, joins <> Empty, joins & vbCrLf & " AND " & LeftAlias & "." & o & " = " & RightAlias & "." & o)
        Next
        
        formatJoin = joins
    
End Function

' ��ʽ������Ŀ���sql => INSERT INTO ${KTL_UDF_SCHEMA_DW}.vt_s_pl_crm_overdue_dk_h
'                        (
'                              ID
'                            , .....
'                            , start_dt
'                            , end_dt
'                            , load_stamp
'                        )
Private Function formatInsertIntoTar() As String

    Dim o, insertFields As String, res As String
        
    For Each o In tableMetaDataDict.keys
    
        If VBA.Left(o, 1) <> "#" Then
            
            If insertFields = Empty Then
                insertFields = vbTab & "  `" & o & "`"
            Else
                insertFields = insertFields & vbCrLf & vbTab & ", `" & o & "`"
            End If
            
        End If
    Next
        
   res = "INSERT INTO ${V_TAR} " _
       & vbCrLf _
       & "(" _
       & vbCrLf _
       & insertFields _
       & vbCrLf _
       & vbTab & ", version    " _
       & vbCrLf _
       & vbTab & ", start_dt   " _
       & vbCrLf _
       & vbTab & ", end_dt     " _
       & vbCrLf _
       & vbTab & ", load_stamp " _
       & vbCrLf _
       & ")" _

       formatInsertIntoTar = res
    
End Function

' ��ʽ������Ŀ���sql =>
'                        SELECT
'                              a.`id`            AS id
'                            , '${MY_DT}'        AS start_dt
'                            , '${MAX_DT}'       AS end_dt
'                            , CURRENT_TIMESTAMP
'                        FROM       ${KTL_UDF_SCHEMA_DW}.crm_overdue_dk                         a
'                        INNER JOIN ${KTL_UDF_SCHEMA_DW}.vt_s_pl_crm_overdue_dk_catlog          b
'                           ON a.id    = b.`k`
'                          AND b.`typ` = 4 /* 'changed' */
'                        ;
Private Function formatSelectChanged() As String

    Dim o, selectFields As String, res As String
        
    For Each o In tableMetaDataDict.keys
        If VBA.Left(o, 1) <> "#" Then
            
            If selectFields = Empty Then
                selectFields = vbTab & "  " & rpad(CStr("a." & o), " ", 30) & " as `" & o & "`"
            Else
                selectFields = selectFields & vbCrLf & vbTab & ", " & rpad(CStr(specialTransform("a." & o, True)), " ", 30) & " as `" & o & "`"
            End If
            
        End If
    Next
            
    res = "SELECT " _
          & vbCrLf _
          & selectFields _
          & vbCrLf _
          & vbTab & ", b.ver + 1         AS version   " _
          & vbCrLf _
          & vbTab & ", ${MY_DT}          AS start_dt  " _
          & vbCrLf _
          & vbTab & ", ${MAX_DT}         AS end_dt    " _
          & vbCrLf _
          & vbTab & ", CURRENT_TIMESTAMP              " _
          & vbCrLf _
          & "FROM       ${SRC_TABLE}                 a" _
          & vbCrLf _
          & "INNER JOIN ${V_CAT}                     b" _
          & vbCrLf _
          & formatJoin("a", "b", keySet()) _
          & vbCrLf _
          & "  AND b.`typ` = 4 /* 'changed' */       " _
          & vbCrLf _
          & " ;"

       formatSelectChanged = res
    
End Function

' ��coalesce���ܵ����⴦���� ��ʱ������͵���ת��Ϊint
Private Function specialTransform(ByVal vField As Variant, Optional ByVal coalesce As Boolean = False) As String

            ' mysql timestamp -> unix version
            Dim t
            t = VBA.Split(vField, ".")
            If CStr(tableMetaDataDict(t(UBound(t)))("FIELD_TYPE")) = "TIMESTAMP" Then
            
                    specialTransform = "UNIX_TIMESTAMP(" & vField & ")"
                    
            ' coalesce process
            ElseIf coalesce _
                    And (VBA.InStr(CStr(tableMetaDataDict(t(UBound(t)))("FIELD_TYPE")), "CHAR") > 0 _
                          Or VBA.InStr(CStr(tableMetaDataDict(t(UBound(t)))("FIELD_TYPE")), "TEXT") > 0 _
                        ) Then  ' CHAR TYPE
                        
                    specialTransform = "COALESCE( " & vField & " , '')"
            Else
                    specialTransform = CStr(vField)
            End If
            
End Function

' ���ַ������ͼ���coalesce����
Private Function coalesce(ByVal vField As String) As String

    Dim t
    t = VBA.Split(vField, ".")
    
    If _
                             VBA.InStr(CStr(tableMetaDataDict(t(UBound(t)))("FIELD_TYPE")), "CHAR") > 0 _
                          Or VBA.InStr(CStr(tableMetaDataDict(t(UBound(t)))("FIELD_TYPE")), "TEXT") > 0 _
    Then  ' CHAR TYPE
                        
        coalesce = "COALESCE( " & vField & " , '')"
    
    Else
        coalesce = vField

    End If
    
End Function

'  �־û����ļ�sql
Private Sub persistence(textCache As Collection, FileName As String)

        Dim objWriter As New FileOperation
             
        ' default
        If FileName = Empty Then
            FileName = "d:\tmp\" & tableMetaDataDict(TAR_TABLE_NAME) & ".sql"
        End If
        
         ' write to file
         objWriter.OpenFile FileName, "W"
        
        For Each o_line In textCache
            objWriter.WriteLine (o_line)
        Next
    
        objWriter.CloseFile
        
End Sub

Private Function replaceVar(ByRef s As String) As String

    Dim result As String
    
    result = s
    
    For Each o In varDict.keys
        result = VBA.Replace(result, o, varDict(o))
    Next o
    
    replaceVar = result

End Function
