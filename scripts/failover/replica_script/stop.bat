rem ***************************************
rem *              stop.bat               *
rem *                                     *
rem * title   : stop script file sample   *
rem * date    : 2007/05/31                *
rem * version : 9.0.3-1                   *
rem ***************************************





rem ***************************************
rem 起動要因チェック
rem ***************************************
IF "%CLP_EVENT%" == "START" GOTO NORMAL
IF "%CLP_EVENT%" == "FAILOVER" GOTO FAILOVER

rem Cluster Server 未動作
GOTO no_arm





rem ***************************************
rem 通常終了対応処理
rem ***************************************
:NORMAL

rem ディスクチェック
IF "%CLP_DISK%" == "FAILURE" GOTO ERROR_DISK


rem *************
rem 業務通常処理
rem *************


rem プライオリティ チェック
IF "%CLP_SERVER%" == "OTHER" GOTO ON_OTHER1

rem *************
rem 最高プライオリティ での処理
rem (例)ARMBCAST /MSG "最高プライオリティサーバで終了中です" /A
rem *************
GOTO EXIT


:ON_OTHER1
rem *************
rem 最高プライオリティ 以外での処理
rem (例)ARMBCAST /MSG "プライオリティサーバ以外で終了です" /A
rem *************
GOTO EXIT





rem ***************************************
rem フェイルオーバ対応処理
rem ***************************************
:FAILOVER

rem ディスクチェック
IF "%CLP_DISK%" == "FAILURE" GOTO ERROR_DISK


rem *************
rem フェイルオーバ後の業務起動ならびに復旧処理
rem *************


rem プライオリティ のチェック
IF "%CLP_SERVER%" == "OTHER" GOTO ON_OTHER2

rem *************
rem 最高プライオリティ での処理
rem (例)ARMBCAST /MSG "最高プライオリティサーバで終了中です（フェイルオーバ後）" /A
rem *************
GOTO EXIT

:ON_OTHER2
rem *************
rem 最高プライオリティ 以外での処理
rem (例)ARMBCAST /MSG "プライオリティサーバ以外で終了中です（フェイルオーバ後）" /A
rem *************
GOTO EXIT




rem ***************************************
rem 例外処理
rem ***************************************

rem ディスク関連エラー処理
:ERROR_DISK
ARMBCAST /MSG "切替パーティションの接続に失敗しました" /A
GOTO EXIT


rem ARM 未動作
:no_arm
ARMBCAST /MSG " Cluster Server が動作状態にありません" /A


:EXIT
