
using System;

namespace TRTCCSharpDemo
{
    partial class TRTCMainForm
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(TRTCMainForm));
            this.panel1 = new System.Windows.Forms.Panel();
            this.otherSettingLabel = new System.Windows.Forms.Label();
            this.vedioSettingLabel = new System.Windows.Forms.Label();
            this.audioSettingLabel = new System.Windows.Forms.Label();
            this.beautyLabel = new System.Windows.Forms.Label();
            this.settingLabel = new System.Windows.Forms.Label();
            this.exitLabel = new System.Windows.Forms.Label();
            this.userLabel = new System.Windows.Forms.Label();
            this.roomLabel = new System.Windows.Forms.Label();
            this.logoPictureBox = new System.Windows.Forms.PictureBox();
            this.logLabel = new System.Windows.Forms.Label();
            this.localUserLabel = new System.Windows.Forms.Label();
            this.remoteUserLabel1 = new System.Windows.Forms.Label();
            this.remoteUserLabel2 = new System.Windows.Forms.Label();
            this.remoteUserLabel3 = new System.Windows.Forms.Label();
            this.localVideoPanel = new System.Windows.Forms.Panel();
            this.localInfoLabel = new System.Windows.Forms.Label();
            this.localVoiceProgressBar = new System.Windows.Forms.ProgressBar();
            this.remoteVideoPanel1 = new System.Windows.Forms.Panel();
            this.remoteInfoLabel1 = new System.Windows.Forms.Label();
            this.remoteVoiceProgressBar1 = new System.Windows.Forms.ProgressBar();
            this.remoteVideoPanel2 = new System.Windows.Forms.Panel();
            this.remoteInfoLabel2 = new System.Windows.Forms.Label();
            this.remoteVoiceProgressBar2 = new System.Windows.Forms.ProgressBar();
            this.remoteVideoPanel3 = new System.Windows.Forms.Panel();
            this.remoteInfoLabel3 = new System.Windows.Forms.Label();
            this.remoteVoiceProgressBar3 = new System.Windows.Forms.ProgressBar();
            this.remoteUserLabel4 = new System.Windows.Forms.Label();
            this.remoteVideoPanel4 = new System.Windows.Forms.Panel();
            this.remoteInfoLabel4 = new System.Windows.Forms.Label();
            this.remoteVoiceProgressBar4 = new System.Windows.Forms.ProgressBar();
            this.remoteUserLabel5 = new System.Windows.Forms.Label();
            this.remoteVideoPanel5 = new System.Windows.Forms.Panel();
            this.remoteInfoLabel5 = new System.Windows.Forms.Label();
            this.remoteVoiceProgressBar5 = new System.Windows.Forms.ProgressBar();
            this.panel2 = new System.Windows.Forms.Panel();
            this.startLocalAudioCheckBox = new System.Windows.Forms.CheckBox();
            this.startLocalPreviewCheckBox = new System.Windows.Forms.CheckBox();
            this.bgmCheckBox = new System.Windows.Forms.CheckBox();
            this.logCheckBox = new System.Windows.Forms.CheckBox();
            this.connectRoomCheckBox = new System.Windows.Forms.CheckBox();
            this.shareUrlLabel = new System.Windows.Forms.Label();
            this.mixTransCodingCheckBox = new System.Windows.Forms.CheckBox();
            this.muteAudioCheckBox = new System.Windows.Forms.CheckBox();
            this.muteVideoCheckBox = new System.Windows.Forms.CheckBox();
            this.screenShareCheckBox = new System.Windows.Forms.CheckBox();
            this.panel1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.logoPictureBox)).BeginInit();
            this.localVideoPanel.SuspendLayout();
            this.remoteVideoPanel1.SuspendLayout();
            this.remoteVideoPanel2.SuspendLayout();
            this.remoteVideoPanel3.SuspendLayout();
            this.remoteVideoPanel4.SuspendLayout();
            this.remoteVideoPanel5.SuspendLayout();
            this.panel2.SuspendLayout();
            this.SuspendLayout();
            // 
            // panel1
            // 
            this.panel1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(38)))), ((int)(((byte)(38)))), ((int)(((byte)(38)))));
            this.panel1.Controls.Add(this.otherSettingLabel);
            this.panel1.Controls.Add(this.vedioSettingLabel);
            this.panel1.Controls.Add(this.audioSettingLabel);
            this.panel1.Controls.Add(this.beautyLabel);
            this.panel1.Controls.Add(this.settingLabel);
            this.panel1.Controls.Add(this.exitLabel);
            this.panel1.Controls.Add(this.userLabel);
            this.panel1.Controls.Add(this.roomLabel);
            this.panel1.Controls.Add(this.logoPictureBox);
            this.panel1.ForeColor = System.Drawing.SystemColors.ControlText;
            this.panel1.Location = new System.Drawing.Point(0, 0);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(1127, 50);
            this.panel1.TabIndex = 0;
            this.panel1.MouseDown += new System.Windows.Forms.MouseEventHandler(this.OnFormMouseDown);
            this.panel1.MouseMove += new System.Windows.Forms.MouseEventHandler(this.OnFormMouseMove);
            this.panel1.MouseUp += new System.Windows.Forms.MouseEventHandler(this.OnFormMouseUp);
            // 
            // otherSettingLabel
            // 
            this.otherSettingLabel.AutoSize = true;
            this.otherSettingLabel.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(38)))), ((int)(((byte)(38)))), ((int)(((byte)(38)))));
            this.otherSettingLabel.Cursor = System.Windows.Forms.Cursors.Hand;
            this.otherSettingLabel.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.otherSettingLabel.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(187)))), ((int)(((byte)(187)))), ((int)(((byte)(187)))));
            this.otherSettingLabel.Location = new System.Drawing.Point(990, 16);
            this.otherSettingLabel.Name = "otherSettingLabel";
            this.otherSettingLabel.Size = new System.Drawing.Size(69, 20);
            this.otherSettingLabel.TabIndex = 12;
            this.otherSettingLabel.Text = "其他设置";
            this.otherSettingLabel.Click += new System.EventHandler(this.otherSettingLabel_Click);
            // 
            // vedioSettingLabel
            // 
            this.vedioSettingLabel.AutoSize = true;
            this.vedioSettingLabel.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(38)))), ((int)(((byte)(38)))), ((int)(((byte)(38)))));
            this.vedioSettingLabel.Cursor = System.Windows.Forms.Cursors.Hand;
            this.vedioSettingLabel.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.vedioSettingLabel.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(187)))), ((int)(((byte)(187)))), ((int)(((byte)(187)))));
            this.vedioSettingLabel.Location = new System.Drawing.Point(756, 16);
            this.vedioSettingLabel.Name = "vedioSettingLabel";
            this.vedioSettingLabel.Size = new System.Drawing.Size(69, 20);
            this.vedioSettingLabel.TabIndex = 11;
            this.vedioSettingLabel.Text = "视频设置";
            this.vedioSettingLabel.Click += new System.EventHandler(this.vedioSettingLabel_Click);
            // 
            // audioSettingLabel
            // 
            this.audioSettingLabel.AutoSize = true;
            this.audioSettingLabel.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(38)))), ((int)(((byte)(38)))), ((int)(((byte)(38)))));
            this.audioSettingLabel.Cursor = System.Windows.Forms.Cursors.Hand;
            this.audioSettingLabel.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.audioSettingLabel.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(187)))), ((int)(((byte)(187)))), ((int)(((byte)(187)))));
            this.audioSettingLabel.Location = new System.Drawing.Point(831, 16);
            this.audioSettingLabel.Name = "audioSettingLabel";
            this.audioSettingLabel.Size = new System.Drawing.Size(69, 20);
            this.audioSettingLabel.TabIndex = 10;
            this.audioSettingLabel.Text = "声音设置";
            this.audioSettingLabel.Click += new System.EventHandler(this.audioSettingLabel_Click);
            // 
            // beautyLabel
            // 
            this.beautyLabel.AutoSize = true;
            this.beautyLabel.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(38)))), ((int)(((byte)(38)))), ((int)(((byte)(38)))));
            this.beautyLabel.Cursor = System.Windows.Forms.Cursors.Hand;
            this.beautyLabel.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.beautyLabel.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(187)))), ((int)(((byte)(187)))), ((int)(((byte)(187)))));
            this.beautyLabel.Location = new System.Drawing.Point(670, 16);
            this.beautyLabel.Name = "beautyLabel";
            this.beautyLabel.Size = new System.Drawing.Size(69, 20);
            this.beautyLabel.TabIndex = 9;
            this.beautyLabel.Text = "美颜设置";
            this.beautyLabel.Click += new System.EventHandler(this.OnBeautyLabelClick);
            // 
            // settingLabel
            // 
            this.settingLabel.AutoSize = true;
            this.settingLabel.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(38)))), ((int)(((byte)(38)))), ((int)(((byte)(38)))));
            this.settingLabel.Cursor = System.Windows.Forms.Cursors.Hand;
            this.settingLabel.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.settingLabel.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(187)))), ((int)(((byte)(187)))), ((int)(((byte)(187)))));
            this.settingLabel.Location = new System.Drawing.Point(906, 16);
            this.settingLabel.Name = "settingLabel";
            this.settingLabel.Size = new System.Drawing.Size(69, 20);
            this.settingLabel.TabIndex = 5;
            this.settingLabel.Text = "常规设置";
            this.settingLabel.Click += new System.EventHandler(this.OnSettingLabelClick);
            // 
            // exitLabel
            // 
            this.exitLabel.AutoSize = true;
            this.exitLabel.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(38)))), ((int)(((byte)(38)))), ((int)(((byte)(38)))));
            this.exitLabel.Cursor = System.Windows.Forms.Cursors.Hand;
            this.exitLabel.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.exitLabel.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(187)))), ((int)(((byte)(187)))), ((int)(((byte)(187)))));
            this.exitLabel.Location = new System.Drawing.Point(1074, 16);
            this.exitLabel.Name = "exitLabel";
            this.exitLabel.Size = new System.Drawing.Size(39, 20);
            this.exitLabel.TabIndex = 4;
            this.exitLabel.Text = "退出";
            this.exitLabel.Click += new System.EventHandler(this.OnExitLabelClick);
            // 
            // userLabel
            // 
            this.userLabel.AutoSize = true;
            this.userLabel.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(38)))), ((int)(((byte)(38)))), ((int)(((byte)(38)))));
            this.userLabel.Cursor = System.Windows.Forms.Cursors.Default;
            this.userLabel.Font = new System.Drawing.Font("微软雅黑", 10.5F);
            this.userLabel.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(187)))), ((int)(((byte)(187)))), ((int)(((byte)(187)))));
            this.userLabel.Location = new System.Drawing.Point(900, 13);
            this.userLabel.Name = "userLabel";
            this.userLabel.Size = new System.Drawing.Size(0, 20);
            this.userLabel.TabIndex = 2;
            // 
            // roomLabel
            // 
            this.roomLabel.AutoSize = true;
            this.roomLabel.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(38)))), ((int)(((byte)(38)))), ((int)(((byte)(38)))));
            this.roomLabel.Cursor = System.Windows.Forms.Cursors.Default;
            this.roomLabel.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.roomLabel.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(187)))), ((int)(((byte)(187)))), ((int)(((byte)(187)))));
            this.roomLabel.Location = new System.Drawing.Point(188, 16);
            this.roomLabel.Name = "roomLabel";
            this.roomLabel.Size = new System.Drawing.Size(39, 20);
            this.roomLabel.TabIndex = 1;
            this.roomLabel.Text = "房间";
            this.roomLabel.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.roomLabel.MouseDown += new System.Windows.Forms.MouseEventHandler(this.OnFormMouseDown);
            this.roomLabel.MouseMove += new System.Windows.Forms.MouseEventHandler(this.OnFormMouseMove);
            this.roomLabel.MouseUp += new System.Windows.Forms.MouseEventHandler(this.OnFormMouseUp);
            // 
            // logoPictureBox
            // 
            this.logoPictureBox.BackgroundImageLayout = System.Windows.Forms.ImageLayout.None;
            this.logoPictureBox.Image = global::TRTCCSharpDemo.Properties.Resources.logo_court_demo;
            this.logoPictureBox.Location = new System.Drawing.Point(7, 4);
            this.logoPictureBox.Name = "logoPictureBox";
            this.logoPictureBox.Size = new System.Drawing.Size(171, 45);
            this.logoPictureBox.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
            this.logoPictureBox.TabIndex = 0;
            this.logoPictureBox.TabStop = false;
            // 
            // logLabel
            // 
            this.logLabel.Location = new System.Drawing.Point(0, 0);
            this.logLabel.Name = "logLabel";
            this.logLabel.Size = new System.Drawing.Size(100, 23);
            this.logLabel.TabIndex = 17;
            // 
            // localUserLabel
            // 
            this.localUserLabel.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.localUserLabel.Location = new System.Drawing.Point(25, 63);
            this.localUserLabel.Name = "localUserLabel";
            this.localUserLabel.Size = new System.Drawing.Size(319, 22);
            this.localUserLabel.TabIndex = 4;
            this.localUserLabel.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // remoteUserLabel1
            // 
            this.remoteUserLabel1.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.remoteUserLabel1.Location = new System.Drawing.Point(405, 63);
            this.remoteUserLabel1.Name = "remoteUserLabel1";
            this.remoteUserLabel1.Size = new System.Drawing.Size(319, 22);
            this.remoteUserLabel1.TabIndex = 5;
            this.remoteUserLabel1.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // remoteUserLabel2
            // 
            this.remoteUserLabel2.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.remoteUserLabel2.Location = new System.Drawing.Point(779, 63);
            this.remoteUserLabel2.Name = "remoteUserLabel2";
            this.remoteUserLabel2.Size = new System.Drawing.Size(319, 22);
            this.remoteUserLabel2.TabIndex = 6;
            this.remoteUserLabel2.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // remoteUserLabel3
            // 
            this.remoteUserLabel3.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.remoteUserLabel3.Location = new System.Drawing.Point(25, 402);
            this.remoteUserLabel3.Name = "remoteUserLabel3";
            this.remoteUserLabel3.Size = new System.Drawing.Size(319, 22);
            this.remoteUserLabel3.TabIndex = 7;
            this.remoteUserLabel3.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // localVideoPanel
            // 
            this.localVideoPanel.BackColor = System.Drawing.SystemColors.Control;
            this.localVideoPanel.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.localVideoPanel.Controls.Add(this.localInfoLabel);
            this.localVideoPanel.Location = new System.Drawing.Point(25, 87);
            this.localVideoPanel.Name = "localVideoPanel";
            this.localVideoPanel.Size = new System.Drawing.Size(320, 290);
            this.localVideoPanel.TabIndex = 8;
            // 
            // localInfoLabel
            // 
            this.localInfoLabel.BackColor = System.Drawing.Color.Gainsboro;
            this.localInfoLabel.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.localInfoLabel.Location = new System.Drawing.Point(0, 0);
            this.localInfoLabel.Margin = new System.Windows.Forms.Padding(0);
            this.localInfoLabel.Name = "localInfoLabel";
            this.localInfoLabel.Size = new System.Drawing.Size(320, 290);
            this.localInfoLabel.TabIndex = 1;
            this.localInfoLabel.Text = "视频已关闭";
            this.localInfoLabel.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.localInfoLabel.Visible = false;
            // 
            // localVoiceProgressBar
            // 
            this.localVoiceProgressBar.ForeColor = System.Drawing.Color.Green;
            this.localVoiceProgressBar.Location = new System.Drawing.Point(25, 377);
            this.localVoiceProgressBar.Margin = new System.Windows.Forms.Padding(0);
            this.localVoiceProgressBar.Name = "localVoiceProgressBar";
            this.localVoiceProgressBar.Size = new System.Drawing.Size(320, 6);
            this.localVoiceProgressBar.TabIndex = 15;
            this.localVoiceProgressBar.Visible = false;
            // 
            // remoteVideoPanel1
            // 
            this.remoteVideoPanel1.BackColor = System.Drawing.SystemColors.Control;
            this.remoteVideoPanel1.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.remoteVideoPanel1.Controls.Add(this.remoteInfoLabel1);
            this.remoteVideoPanel1.Location = new System.Drawing.Point(405, 87);
            this.remoteVideoPanel1.Name = "remoteVideoPanel1";
            this.remoteVideoPanel1.Size = new System.Drawing.Size(320, 290);
            this.remoteVideoPanel1.TabIndex = 9;
            // 
            // remoteInfoLabel1
            // 
            this.remoteInfoLabel1.BackColor = System.Drawing.Color.Gainsboro;
            this.remoteInfoLabel1.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.remoteInfoLabel1.Location = new System.Drawing.Point(0, 0);
            this.remoteInfoLabel1.Margin = new System.Windows.Forms.Padding(0);
            this.remoteInfoLabel1.Name = "remoteInfoLabel1";
            this.remoteInfoLabel1.Size = new System.Drawing.Size(320, 290);
            this.remoteInfoLabel1.TabIndex = 0;
            this.remoteInfoLabel1.Text = "对方未开启视频";
            this.remoteInfoLabel1.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.remoteInfoLabel1.Visible = false;
            // 
            // remoteVoiceProgressBar1
            // 
            this.remoteVoiceProgressBar1.ForeColor = System.Drawing.Color.Green;
            this.remoteVoiceProgressBar1.Location = new System.Drawing.Point(405, 377);
            this.remoteVoiceProgressBar1.Margin = new System.Windows.Forms.Padding(0);
            this.remoteVoiceProgressBar1.Name = "remoteVoiceProgressBar1";
            this.remoteVoiceProgressBar1.Size = new System.Drawing.Size(320, 6);
            this.remoteVoiceProgressBar1.TabIndex = 16;
            this.remoteVoiceProgressBar1.Visible = false;
            // 
            // remoteVideoPanel2
            // 
            this.remoteVideoPanel2.BackColor = System.Drawing.SystemColors.Control;
            this.remoteVideoPanel2.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.remoteVideoPanel2.Controls.Add(this.remoteInfoLabel2);
            this.remoteVideoPanel2.Location = new System.Drawing.Point(779, 87);
            this.remoteVideoPanel2.Name = "remoteVideoPanel2";
            this.remoteVideoPanel2.Size = new System.Drawing.Size(320, 290);
            this.remoteVideoPanel2.TabIndex = 10;
            // 
            // remoteInfoLabel2
            // 
            this.remoteInfoLabel2.BackColor = System.Drawing.Color.Gainsboro;
            this.remoteInfoLabel2.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.remoteInfoLabel2.Location = new System.Drawing.Point(0, 0);
            this.remoteInfoLabel2.Margin = new System.Windows.Forms.Padding(0);
            this.remoteInfoLabel2.Name = "remoteInfoLabel2";
            this.remoteInfoLabel2.Size = new System.Drawing.Size(320, 290);
            this.remoteInfoLabel2.TabIndex = 1;
            this.remoteInfoLabel2.Text = "对方未开启视频";
            this.remoteInfoLabel2.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.remoteInfoLabel2.Visible = false;
            // 
            // remoteVoiceProgressBar2
            // 
            this.remoteVoiceProgressBar2.ForeColor = System.Drawing.Color.Green;
            this.remoteVoiceProgressBar2.Location = new System.Drawing.Point(779, 377);
            this.remoteVoiceProgressBar2.Margin = new System.Windows.Forms.Padding(0);
            this.remoteVoiceProgressBar2.Name = "remoteVoiceProgressBar2";
            this.remoteVoiceProgressBar2.Size = new System.Drawing.Size(320, 6);
            this.remoteVoiceProgressBar2.TabIndex = 17;
            this.remoteVoiceProgressBar2.Visible = false;
            // 
            // remoteVideoPanel3
            // 
            this.remoteVideoPanel3.BackColor = System.Drawing.SystemColors.Control;
            this.remoteVideoPanel3.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.remoteVideoPanel3.Controls.Add(this.remoteInfoLabel3);
            this.remoteVideoPanel3.Location = new System.Drawing.Point(25, 426);
            this.remoteVideoPanel3.Name = "remoteVideoPanel3";
            this.remoteVideoPanel3.Size = new System.Drawing.Size(320, 290);
            this.remoteVideoPanel3.TabIndex = 9;
            // 
            // remoteInfoLabel3
            // 
            this.remoteInfoLabel3.BackColor = System.Drawing.Color.Gainsboro;
            this.remoteInfoLabel3.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.remoteInfoLabel3.Location = new System.Drawing.Point(0, 0);
            this.remoteInfoLabel3.Margin = new System.Windows.Forms.Padding(0);
            this.remoteInfoLabel3.Name = "remoteInfoLabel3";
            this.remoteInfoLabel3.Size = new System.Drawing.Size(320, 290);
            this.remoteInfoLabel3.TabIndex = 2;
            this.remoteInfoLabel3.Text = "对方未开启视频";
            this.remoteInfoLabel3.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.remoteInfoLabel3.Visible = false;
            // 
            // remoteVoiceProgressBar3
            // 
            this.remoteVoiceProgressBar3.ForeColor = System.Drawing.Color.Green;
            this.remoteVoiceProgressBar3.Location = new System.Drawing.Point(25, 716);
            this.remoteVoiceProgressBar3.Margin = new System.Windows.Forms.Padding(0);
            this.remoteVoiceProgressBar3.Name = "remoteVoiceProgressBar3";
            this.remoteVoiceProgressBar3.Size = new System.Drawing.Size(320, 6);
            this.remoteVoiceProgressBar3.TabIndex = 18;
            this.remoteVoiceProgressBar3.Visible = false;
            // 
            // remoteUserLabel4
            // 
            this.remoteUserLabel4.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.remoteUserLabel4.Location = new System.Drawing.Point(405, 402);
            this.remoteUserLabel4.Name = "remoteUserLabel4";
            this.remoteUserLabel4.Size = new System.Drawing.Size(319, 22);
            this.remoteUserLabel4.TabIndex = 10;
            this.remoteUserLabel4.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // remoteVideoPanel4
            // 
            this.remoteVideoPanel4.BackColor = System.Drawing.SystemColors.Control;
            this.remoteVideoPanel4.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.remoteVideoPanel4.Controls.Add(this.remoteInfoLabel4);
            this.remoteVideoPanel4.Location = new System.Drawing.Point(405, 426);
            this.remoteVideoPanel4.Name = "remoteVideoPanel4";
            this.remoteVideoPanel4.Size = new System.Drawing.Size(320, 290);
            this.remoteVideoPanel4.TabIndex = 11;
            // 
            // remoteInfoLabel4
            // 
            this.remoteInfoLabel4.BackColor = System.Drawing.Color.Gainsboro;
            this.remoteInfoLabel4.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.remoteInfoLabel4.Location = new System.Drawing.Point(0, 0);
            this.remoteInfoLabel4.Margin = new System.Windows.Forms.Padding(0);
            this.remoteInfoLabel4.Name = "remoteInfoLabel4";
            this.remoteInfoLabel4.Size = new System.Drawing.Size(320, 290);
            this.remoteInfoLabel4.TabIndex = 1;
            this.remoteInfoLabel4.Text = "对方未开启视频";
            this.remoteInfoLabel4.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.remoteInfoLabel4.Visible = false;
            // 
            // remoteVoiceProgressBar4
            // 
            this.remoteVoiceProgressBar4.ForeColor = System.Drawing.Color.Green;
            this.remoteVoiceProgressBar4.Location = new System.Drawing.Point(405, 716);
            this.remoteVoiceProgressBar4.Margin = new System.Windows.Forms.Padding(0);
            this.remoteVoiceProgressBar4.Name = "remoteVoiceProgressBar4";
            this.remoteVoiceProgressBar4.Size = new System.Drawing.Size(320, 6);
            this.remoteVoiceProgressBar4.TabIndex = 19;
            this.remoteVoiceProgressBar4.Visible = false;
            // 
            // remoteUserLabel5
            // 
            this.remoteUserLabel5.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.remoteUserLabel5.Location = new System.Drawing.Point(779, 402);
            this.remoteUserLabel5.Name = "remoteUserLabel5";
            this.remoteUserLabel5.Size = new System.Drawing.Size(319, 22);
            this.remoteUserLabel5.TabIndex = 12;
            this.remoteUserLabel5.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // remoteVideoPanel5
            // 
            this.remoteVideoPanel5.BackColor = System.Drawing.SystemColors.Control;
            this.remoteVideoPanel5.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.remoteVideoPanel5.Controls.Add(this.remoteInfoLabel5);
            this.remoteVideoPanel5.Location = new System.Drawing.Point(779, 426);
            this.remoteVideoPanel5.Name = "remoteVideoPanel5";
            this.remoteVideoPanel5.Size = new System.Drawing.Size(319, 289);
            this.remoteVideoPanel5.TabIndex = 13;
            // 
            // remoteInfoLabel5
            // 
            this.remoteInfoLabel5.BackColor = System.Drawing.Color.Gainsboro;
            this.remoteInfoLabel5.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.remoteInfoLabel5.Location = new System.Drawing.Point(0, 0);
            this.remoteInfoLabel5.Margin = new System.Windows.Forms.Padding(0);
            this.remoteInfoLabel5.Name = "remoteInfoLabel5";
            this.remoteInfoLabel5.Size = new System.Drawing.Size(320, 290);
            this.remoteInfoLabel5.TabIndex = 2;
            this.remoteInfoLabel5.Text = "对方未开启视频";
            this.remoteInfoLabel5.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.remoteInfoLabel5.Visible = false;
            // 
            // remoteVoiceProgressBar5
            // 
            this.remoteVoiceProgressBar5.ForeColor = System.Drawing.Color.Green;
            this.remoteVoiceProgressBar5.Location = new System.Drawing.Point(779, 716);
            this.remoteVoiceProgressBar5.Margin = new System.Windows.Forms.Padding(0);
            this.remoteVoiceProgressBar5.Name = "remoteVoiceProgressBar5";
            this.remoteVoiceProgressBar5.Size = new System.Drawing.Size(320, 6);
            this.remoteVoiceProgressBar5.TabIndex = 20;
            this.remoteVoiceProgressBar5.Visible = false;
            // 
            // panel2
            // 
            this.panel2.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(38)))), ((int)(((byte)(38)))), ((int)(((byte)(38)))));
            this.panel2.Controls.Add(this.startLocalAudioCheckBox);
            this.panel2.Controls.Add(this.startLocalPreviewCheckBox);
            this.panel2.Controls.Add(this.bgmCheckBox);
            this.panel2.Controls.Add(this.logCheckBox);
            this.panel2.Controls.Add(this.connectRoomCheckBox);
            this.panel2.Controls.Add(this.shareUrlLabel);
            this.panel2.Controls.Add(this.mixTransCodingCheckBox);
            this.panel2.Controls.Add(this.muteAudioCheckBox);
            this.panel2.Controls.Add(this.muteVideoCheckBox);
            this.panel2.Controls.Add(this.screenShareCheckBox);
            this.panel2.Controls.Add(this.logLabel);
            this.panel2.Location = new System.Drawing.Point(0, 731);
            this.panel2.Name = "panel2";
            this.panel2.Size = new System.Drawing.Size(1127, 45);
            this.panel2.TabIndex = 14;
            // 
            // startLocalAudioCheckBox
            // 
            this.startLocalAudioCheckBox.AutoSize = true;
            this.startLocalAudioCheckBox.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.startLocalAudioCheckBox.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(187)))), ((int)(((byte)(187)))), ((int)(((byte)(187)))));
            this.startLocalAudioCheckBox.Location = new System.Drawing.Point(101, 12);
            this.startLocalAudioCheckBox.Name = "startLocalAudioCheckBox";
            this.startLocalAudioCheckBox.Size = new System.Drawing.Size(88, 24);
            this.startLocalAudioCheckBox.TabIndex = 19;
            this.startLocalAudioCheckBox.Text = "采集音频";
            this.startLocalAudioCheckBox.UseVisualStyleBackColor = true;
            this.startLocalAudioCheckBox.Click += new System.EventHandler(this.OnStartLocalAudioClick);
            // 
            // startLocalPreviewCheckBox
            // 
            this.startLocalPreviewCheckBox.AutoSize = true;
            this.startLocalPreviewCheckBox.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.startLocalPreviewCheckBox.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(187)))), ((int)(((byte)(187)))), ((int)(((byte)(187)))));
            this.startLocalPreviewCheckBox.Location = new System.Drawing.Point(7, 12);
            this.startLocalPreviewCheckBox.Name = "startLocalPreviewCheckBox";
            this.startLocalPreviewCheckBox.Size = new System.Drawing.Size(88, 24);
            this.startLocalPreviewCheckBox.TabIndex = 18;
            this.startLocalPreviewCheckBox.Text = "采集视频";
            this.startLocalPreviewCheckBox.UseVisualStyleBackColor = true;
            this.startLocalPreviewCheckBox.Click += new System.EventHandler(this.OnStartLocalPreviewClick);
            // 
            // bgmCheckBox
            // 
            this.bgmCheckBox.AutoSize = true;
            this.bgmCheckBox.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.bgmCheckBox.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(187)))), ((int)(((byte)(187)))), ((int)(((byte)(187)))));
            this.bgmCheckBox.Location = new System.Drawing.Point(405, 12);
            this.bgmCheckBox.Name = "bgmCheckBox";
            this.bgmCheckBox.Size = new System.Drawing.Size(88, 24);
            this.bgmCheckBox.TabIndex = 16;
            this.bgmCheckBox.Text = "背景音乐";
            this.bgmCheckBox.UseVisualStyleBackColor = true;
            this.bgmCheckBox.Click += new System.EventHandler(this.OnBgmCheckBoxClick);
            // 
            // logCheckBox
            // 
            this.logCheckBox.AutoSize = true;
            this.logCheckBox.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.logCheckBox.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(187)))), ((int)(((byte)(187)))), ((int)(((byte)(187)))));
            this.logCheckBox.Location = new System.Drawing.Point(722, 12);
            this.logCheckBox.Name = "logCheckBox";
            this.logCheckBox.Size = new System.Drawing.Size(73, 24);
            this.logCheckBox.TabIndex = 15;
            this.logCheckBox.Text = "仪表盘";
            this.logCheckBox.UseVisualStyleBackColor = true;
            this.logCheckBox.Click += new System.EventHandler(this.OnLogCheckBoxClick);
            // 
            // connectRoomCheckBox
            // 
            this.connectRoomCheckBox.AutoSize = true;
            this.connectRoomCheckBox.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.connectRoomCheckBox.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(187)))), ((int)(((byte)(187)))), ((int)(((byte)(187)))));
            this.connectRoomCheckBox.Location = new System.Drawing.Point(617, 12);
            this.connectRoomCheckBox.Name = "connectRoomCheckBox";
            this.connectRoomCheckBox.Size = new System.Drawing.Size(88, 24);
            this.connectRoomCheckBox.TabIndex = 14;
            this.connectRoomCheckBox.Text = "跨房通话";
            this.connectRoomCheckBox.UseVisualStyleBackColor = true;
            this.connectRoomCheckBox.Click += new System.EventHandler(this.OnConnectRoomCheckBoxClick);
            // 
            // shareUrlLabel
            // 
            this.shareUrlLabel.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(38)))), ((int)(((byte)(38)))), ((int)(((byte)(38)))));
            this.shareUrlLabel.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.shareUrlLabel.Cursor = System.Windows.Forms.Cursors.Hand;
            this.shareUrlLabel.Font = new System.Drawing.Font("微软雅黑", 11F, System.Drawing.FontStyle.Bold);
            this.shareUrlLabel.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(187)))), ((int)(((byte)(187)))), ((int)(((byte)(187)))));
            this.shareUrlLabel.Location = new System.Drawing.Point(936, 10);
            this.shareUrlLabel.Name = "shareUrlLabel";
            this.shareUrlLabel.Size = new System.Drawing.Size(105, 25);
            this.shareUrlLabel.TabIndex = 8;
            this.shareUrlLabel.Text = "分享播放地址";
            this.shareUrlLabel.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.shareUrlLabel.Click += new System.EventHandler(this.OnShareUrlLabelClick);
            // 
            // mixTransCodingCheckBox
            // 
            this.mixTransCodingCheckBox.AutoSize = true;
            this.mixTransCodingCheckBox.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.mixTransCodingCheckBox.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(187)))), ((int)(((byte)(187)))), ((int)(((byte)(187)))));
            this.mixTransCodingCheckBox.Location = new System.Drawing.Point(812, 12);
            this.mixTransCodingCheckBox.Name = "mixTransCodingCheckBox";
            this.mixTransCodingCheckBox.Size = new System.Drawing.Size(118, 24);
            this.mixTransCodingCheckBox.TabIndex = 12;
            this.mixTransCodingCheckBox.Text = "云端画面混合";
            this.mixTransCodingCheckBox.UseVisualStyleBackColor = true;
            this.mixTransCodingCheckBox.Click += new System.EventHandler(this.OnMixTransCodingCheckBoxClick);
            // 
            // muteAudioCheckBox
            // 
            this.muteAudioCheckBox.AutoSize = true;
            this.muteAudioCheckBox.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.muteAudioCheckBox.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(187)))), ((int)(((byte)(187)))), ((int)(((byte)(187)))));
            this.muteAudioCheckBox.Location = new System.Drawing.Point(301, 12);
            this.muteAudioCheckBox.Name = "muteAudioCheckBox";
            this.muteAudioCheckBox.Size = new System.Drawing.Size(88, 24);
            this.muteAudioCheckBox.TabIndex = 10;
            this.muteAudioCheckBox.Text = "屏蔽音频";
            this.muteAudioCheckBox.UseVisualStyleBackColor = true;
            this.muteAudioCheckBox.Click += new System.EventHandler(this.OnMuteAudioCheckBoxClick);
            // 
            // muteVideoCheckBox
            // 
            this.muteVideoCheckBox.AutoSize = true;
            this.muteVideoCheckBox.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.muteVideoCheckBox.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(187)))), ((int)(((byte)(187)))), ((int)(((byte)(187)))));
            this.muteVideoCheckBox.Location = new System.Drawing.Point(195, 12);
            this.muteVideoCheckBox.Name = "muteVideoCheckBox";
            this.muteVideoCheckBox.Size = new System.Drawing.Size(88, 24);
            this.muteVideoCheckBox.TabIndex = 9;
            this.muteVideoCheckBox.Text = "屏蔽视频";
            this.muteVideoCheckBox.UseVisualStyleBackColor = true;
            this.muteVideoCheckBox.Click += new System.EventHandler(this.OnMuteVideoCheckBoxClick);
            // 
            // screenShareCheckBox
            // 
            this.screenShareCheckBox.AutoSize = true;
            this.screenShareCheckBox.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.screenShareCheckBox.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(187)))), ((int)(((byte)(187)))), ((int)(((byte)(187)))));
            this.screenShareCheckBox.Location = new System.Drawing.Point(509, 12);
            this.screenShareCheckBox.Name = "screenShareCheckBox";
            this.screenShareCheckBox.Size = new System.Drawing.Size(88, 24);
            this.screenShareCheckBox.TabIndex = 8;
            this.screenShareCheckBox.Text = "屏幕共享";
            this.screenShareCheckBox.UseVisualStyleBackColor = true;
            this.screenShareCheckBox.Click += new System.EventHandler(this.OnScreenShareCheckBoxClick);
            // 
            // TRTCMainForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(96F, 96F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Dpi;
            this.BackColor = System.Drawing.SystemColors.Control;
            this.ClientSize = new System.Drawing.Size(1127, 776);
            this.Controls.Add(this.remoteVoiceProgressBar5);
            this.Controls.Add(this.localVoiceProgressBar);
            this.Controls.Add(this.remoteVoiceProgressBar4);
            this.Controls.Add(this.remoteVoiceProgressBar3);
            this.Controls.Add(this.remoteVoiceProgressBar2);
            this.Controls.Add(this.remoteVoiceProgressBar1);
            this.Controls.Add(this.panel2);
            this.Controls.Add(this.remoteUserLabel5);
            this.Controls.Add(this.remoteVideoPanel5);
            this.Controls.Add(this.remoteUserLabel4);
            this.Controls.Add(this.remoteVideoPanel4);
            this.Controls.Add(this.remoteUserLabel3);
            this.Controls.Add(this.remoteUserLabel2);
            this.Controls.Add(this.remoteUserLabel1);
            this.Controls.Add(this.localUserLabel);
            this.Controls.Add(this.panel1);
            this.Controls.Add(this.localVideoPanel);
            this.Controls.Add(this.remoteVideoPanel1);
            this.Controls.Add(this.remoteVideoPanel2);
            this.Controls.Add(this.remoteVideoPanel3);
            this.Cursor = System.Windows.Forms.Cursors.Default;
            this.DoubleBuffered = true;
            this.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.Name = "TRTCMainForm";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "TRTCCSharpDemo";
            this.Load += new System.EventHandler(this.OnFormLoad);
            this.MouseDown += new System.Windows.Forms.MouseEventHandler(this.OnFormMouseDown);
            this.MouseMove += new System.Windows.Forms.MouseEventHandler(this.OnFormMouseMove);
            this.MouseUp += new System.Windows.Forms.MouseEventHandler(this.OnFormMouseUp);
            this.panel1.ResumeLayout(false);
            this.panel1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.logoPictureBox)).EndInit();
            this.localVideoPanel.ResumeLayout(false);
            this.remoteVideoPanel1.ResumeLayout(false);
            this.remoteVideoPanel2.ResumeLayout(false);
            this.remoteVideoPanel3.ResumeLayout(false);
            this.remoteVideoPanel4.ResumeLayout(false);
            this.remoteVideoPanel5.ResumeLayout(false);
            this.panel2.ResumeLayout(false);
            this.panel2.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.PictureBox logoPictureBox;
        public System.Windows.Forms.Label userLabel;
        public System.Windows.Forms.Label roomLabel;
        private System.Windows.Forms.Label exitLabel;
        private System.Windows.Forms.Label localUserLabel;
        private System.Windows.Forms.Label remoteUserLabel1;
        private System.Windows.Forms.Label remoteUserLabel2;
        private System.Windows.Forms.Label remoteUserLabel3;
        private System.Windows.Forms.Panel localVideoPanel;
        private System.Windows.Forms.Panel remoteVideoPanel1;
        private System.Windows.Forms.Panel remoteVideoPanel2;
        private System.Windows.Forms.Panel remoteVideoPanel3;
        private System.Windows.Forms.Label settingLabel;
        private System.Windows.Forms.Label logLabel;
        private System.Windows.Forms.Label remoteUserLabel4;
        private System.Windows.Forms.Panel remoteVideoPanel4;
        private System.Windows.Forms.Label remoteUserLabel5;
        private System.Windows.Forms.Panel remoteVideoPanel5;
        private System.Windows.Forms.Panel panel2;
        private System.Windows.Forms.CheckBox screenShareCheckBox;
        private System.Windows.Forms.Label remoteInfoLabel1;
        private System.Windows.Forms.Label remoteInfoLabel2;
        private System.Windows.Forms.Label remoteInfoLabel3;
        private System.Windows.Forms.Label remoteInfoLabel4;
        private System.Windows.Forms.Label remoteInfoLabel5;
        private System.Windows.Forms.Label localInfoLabel;
        private System.Windows.Forms.CheckBox muteVideoCheckBox;
        private System.Windows.Forms.CheckBox muteAudioCheckBox;
        private System.Windows.Forms.CheckBox mixTransCodingCheckBox;
        private System.Windows.Forms.Label shareUrlLabel;
        private System.Windows.Forms.Label beautyLabel;
        private System.Windows.Forms.CheckBox connectRoomCheckBox;
        private System.Windows.Forms.ProgressBar localVoiceProgressBar;
        private System.Windows.Forms.ProgressBar remoteVoiceProgressBar1;
        private System.Windows.Forms.ProgressBar remoteVoiceProgressBar2;
        private System.Windows.Forms.ProgressBar remoteVoiceProgressBar3;
        private System.Windows.Forms.ProgressBar remoteVoiceProgressBar5;
        private System.Windows.Forms.ProgressBar remoteVoiceProgressBar4;
        private System.Windows.Forms.Label otherSettingLabel;
        private System.Windows.Forms.Label vedioSettingLabel;
        private System.Windows.Forms.Label audioSettingLabel;
        private System.Windows.Forms.CheckBox bgmCheckBox;
        private System.Windows.Forms.CheckBox logCheckBox;
        private System.Windows.Forms.CheckBox startLocalAudioCheckBox;
        private System.Windows.Forms.CheckBox startLocalPreviewCheckBox;
    }
}