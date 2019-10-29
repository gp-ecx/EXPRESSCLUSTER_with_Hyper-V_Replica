rem ***************************************
rem *              stop.bat               *
rem *                                     *
rem * title   : stop script file sample   *
rem * date    : 2019/10/28                *
rem * version : 9.0.3-1                   *
rem ***************************************


cd "%CLP_SCRIPT_PATH%"
call cluster_config.bat


rem ***************************************
rem �N���v���`�F�b�N
rem ***************************************
IF "%CLP_EVENT%" == "START" GOTO NORMAL
IF "%CLP_EVENT%" == "FAILOVER" GOTO FAILOVER

rem Cluster Server ������
GOTO no_arm





rem ***************************************
rem �ʏ�I���Ή�����
rem ***************************************
:NORMAL

rem �f�B�X�N�`�F�b�N
IF "%CLP_DISK%" == "FAILURE" GOTO ERROR_DISK


rem *************
rem �Ɩ��ʏ폈��
rem *************

armload REPSTOP /U Administrator /W powershell.exe .\stop.ps1
armkill REPSTOP

rem �v���C�I���e�B �`�F�b�N
IF "%CLP_SERVER%" == "OTHER" GOTO ON_OTHER1

rem *************
rem �ō��v���C�I���e�B �ł̏���
rem (��)ARMBCAST /MSG "�ō��v���C�I���e�B�T�[�o�ŏI�����ł�" /A
rem *************
GOTO EXIT


:ON_OTHER1
rem *************
rem �ō��v���C�I���e�B �ȊO�ł̏���
rem (��)ARMBCAST /MSG "�v���C�I���e�B�T�[�o�ȊO�ŏI���ł�" /A
rem *************
GOTO EXIT





rem ***************************************
rem �t�F�C���I�[�o�Ή�����
rem ***************************************
:FAILOVER

rem �f�B�X�N�`�F�b�N
IF "%CLP_DISK%" == "FAILURE" GOTO ERROR_DISK


rem *************
rem �t�F�C���I�[�o��̋Ɩ��N���Ȃ�тɕ�������
rem *************

armload REPSTOP /U Administrator /W powershell.exe .\stop.ps1
armkill REPSTOP

rem �v���C�I���e�B �̃`�F�b�N
IF "%CLP_SERVER%" == "OTHER" GOTO ON_OTHER2

rem *************
rem �ō��v���C�I���e�B �ł̏���
rem (��)ARMBCAST /MSG "�ō��v���C�I���e�B�T�[�o�ŏI�����ł��i�t�F�C���I�[�o��j" /A
rem *************
GOTO EXIT

:ON_OTHER2
rem *************
rem �ō��v���C�I���e�B �ȊO�ł̏���
rem (��)ARMBCAST /MSG "�v���C�I���e�B�T�[�o�ȊO�ŏI�����ł��i�t�F�C���I�[�o��j" /A
rem *************
GOTO EXIT




rem ***************************************
rem ��O����
rem ***************************************

rem �f�B�X�N�֘A�G���[����
:ERROR_DISK
ARMBCAST /MSG "�ؑփp�[�e�B�V�����̐ڑ��Ɏ��s���܂���" /A
GOTO EXIT


rem ARM ������
:no_arm
ARMBCAST /MSG " Cluster Server �������Ԃɂ���܂���" /A


:EXIT
