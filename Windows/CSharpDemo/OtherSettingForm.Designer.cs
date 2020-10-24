namespace TRTCCSharpDemo
{
    partial class OtherSettingForm
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
            this.panel1 = new System.Windows.Forms.Panel();
            this.exitPicBox = new System.Windows.Forms.PictureBox();
            this.label1 = new System.Windows.Forms.Label();
            this.voiceCheckBox = new System.Windows.Forms.CheckBox();
            this.mirrorCheckBox = new System.Windows.Forms.CheckBox();
            this.customVideoComboBox = new System.Windows.Forms.ComboBox();
            this.customAudioComboBox = new System.Windows.Forms.ComboBox();
            this.customVideoCheckBox = new System.Windows.Forms.CheckBox();
            this.customAudioCheckBox = new System.Windows.Forms.CheckBox();
            this.audioRecordBtn = new System.Windows.Forms.Button();
            this.roomLabel = new System.Windows.Forms.Label();
            this.roomPanel = new System.Windows.Forms.Panel();
            this.roomIdTextBox = new System.Windows.Forms.TextBox();
            this.label2 = new System.Windows.Forms.Label();
            this.panel2 = new System.Windows.Forms.Panel();
            this.strRoomIdTextBox = new System.Windows.Forms.TextBox();
            this.switchRoomBtn = new System.Windows.Forms.Button();
            this.label3 = new System.Windows.Forms.Label();
            this.panel3 = new System.Windows.Forms.Panel();
            this.addHwndTextBox = new System.Windows.Forms.TextBox();
            this.addHwndBtn = new System.Windows.Forms.Button();
            this.removeHwndBtn = new System.Windows.Forms.Button();
            this.label4 = new System.Windows.Forms.Label();
            this.panel4 = new System.Windows.Forms.Panel();
            this.removeHwndTextBox = new System.Windows.Forms.TextBox();
            this.removeAllHwndBtn = new System.Windows.Forms.Button();
            this.panel1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.exitPicBox)).BeginInit();
            this.roomPanel.SuspendLayout();
            this.panel2.SuspendLayout();
            this.panel3.SuspendLayout();
            this.panel4.SuspendLayout();
            this.SuspendLayout();
            // 
            // panel1
            // 
            this.panel1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(38)))), ((int)(((byte)(38)))), ((int)(((byte)(38)))));
            this.panel1.Controls.Add(this.exitPicBox);
            this.panel1.Controls.Add(this.label1);
            this.panel1.Location = new System.Drawing.Point(1, 1);
            this.panel1.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(375, 39);
            this.panel1.TabIndex = 4;
            this.panel1.MouseDown += new System.Windows.Forms.MouseEventHandler(this.OnFormMouseDown);
            this.panel1.MouseMove += new System.Windows.Forms.MouseEventHandler(this.OnFormMouseMove);
            this.panel1.MouseUp += new System.Windows.Forms.MouseEventHandler(this.OnFormMouseUp);
            // 
            // exitPicBox
            // 
            this.exitPicBox.BackgroundImage = global::TRTCCSharpDemo.Properties.Resources.close_white;
            this.exitPicBox.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Zoom;
            this.exitPicBox.Cursor = System.Windows.Forms.Cursors.Hand;
            this.exitPicBox.Location = new System.Drawing.Point(346, 9);
            this.exitPicBox.Name = "exitPicBox";
            this.exitPicBox.Size = new System.Drawing.Size(23, 23);
            this.exitPicBox.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.exitPicBox.TabIndex = 25;
            this.exitPicBox.TabStop = false;
            this.exitPicBox.Click += new System.EventHandler(this.exitPicBox_Click);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Cursor = System.Windows.Forms.Cursors.Default;
            this.label1.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.label1.ForeColor = System.Drawing.Color.White;
            this.label1.Location = new System.Drawing.Point(11, 9);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(74, 21);
            this.label1.TabIndex = 0;
            this.label1.Text = "其他设置";
            // 
            // voiceCheckBox
            // 
            this.voiceCheckBox.AutoSize = true;
            this.voiceCheckBox.Font = new System.Drawing.Font("微软雅黑", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.voiceCheckBox.ForeColor = System.Drawing.SystemColors.ControlText;
            this.voiceCheckBox.Location = new System.Drawing.Point(145, 69);
            this.voiceCheckBox.Name = "voiceCheckBox";
            this.voiceCheckBox.Size = new System.Drawing.Size(125, 25);
            this.voiceCheckBox.TabIndex = 19;
            this.voiceCheckBox.Text = "开启音量提示";
            this.voiceCheckBox.UseVisualStyleBackColor = true;
            this.voiceCheckBox.Click += new System.EventHandler(this.OnVoiceCheckBoxClick);
            // 
            // mirrorCheckBox
            // 
            this.mirrorCheckBox.AutoSize = true;
            this.mirrorCheckBox.Font = new System.Drawing.Font("微软雅黑", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.mirrorCheckBox.ForeColor = System.Drawing.SystemColors.ControlText;
            this.mirrorCheckBox.Location = new System.Drawing.Point(25, 69);
            this.mirrorCheckBox.Name = "mirrorCheckBox";
            this.mirrorCheckBox.Size = new System.Drawing.Size(93, 25);
            this.mirrorCheckBox.TabIndex = 17;
            this.mirrorCheckBox.Text = "开启镜像";
            this.mirrorCheckBox.UseVisualStyleBackColor = true;
            this.mirrorCheckBox.Click += new System.EventHandler(this.OnMirrorCheckBoxClick);
            // 
            // customVideoComboBox
            // 
            this.customVideoComboBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.customVideoComboBox.Font = new System.Drawing.Font("微软雅黑", 10F);
            this.customVideoComboBox.FormattingEnabled = true;
            this.customVideoComboBox.Location = new System.Drawing.Point(176, 175);
            this.customVideoComboBox.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.customVideoComboBox.Name = "customVideoComboBox";
            this.customVideoComboBox.Size = new System.Drawing.Size(164, 27);
            this.customVideoComboBox.TabIndex = 41;
            // 
            // customAudioComboBox
            // 
            this.customAudioComboBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.customAudioComboBox.Font = new System.Drawing.Font("微软雅黑", 10F);
            this.customAudioComboBox.FormattingEnabled = true;
            this.customAudioComboBox.Location = new System.Drawing.Point(176, 118);
            this.customAudioComboBox.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.customAudioComboBox.Name = "customAudioComboBox";
            this.customAudioComboBox.Size = new System.Drawing.Size(164, 27);
            this.customAudioComboBox.TabIndex = 40;
            // 
            // customVideoCheckBox
            // 
            this.customVideoCheckBox.AutoSize = true;
            this.customVideoCheckBox.CheckAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.customVideoCheckBox.Cursor = System.Windows.Forms.Cursors.Hand;
            this.customVideoCheckBox.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.customVideoCheckBox.ForeColor = System.Drawing.SystemColors.ControlText;
            this.customVideoCheckBox.Location = new System.Drawing.Point(20, 175);
            this.customVideoCheckBox.Name = "customVideoCheckBox";
            this.customVideoCheckBox.Size = new System.Drawing.Size(141, 25);
            this.customVideoCheckBox.TabIndex = 39;
            this.customVideoCheckBox.Text = "自定义采集视频";
            this.customVideoCheckBox.UseVisualStyleBackColor = true;
            this.customVideoCheckBox.Click += new System.EventHandler(this.OnCustomVideoCheckBoxClick);
            // 
            // customAudioCheckBox
            // 
            this.customAudioCheckBox.AutoSize = true;
            this.customAudioCheckBox.CheckAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.customAudioCheckBox.Cursor = System.Windows.Forms.Cursors.Hand;
            this.customAudioCheckBox.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.customAudioCheckBox.ForeColor = System.Drawing.SystemColors.ControlText;
            this.customAudioCheckBox.Location = new System.Drawing.Point(20, 119);
            this.customAudioCheckBox.Name = "customAudioCheckBox";
            this.customAudioCheckBox.Size = new System.Drawing.Size(141, 25);
            this.customAudioCheckBox.TabIndex = 38;
            this.customAudioCheckBox.Text = "自定义采集音频";
            this.customAudioCheckBox.UseVisualStyleBackColor = true;
            this.customAudioCheckBox.Click += new System.EventHandler(this.OnCustomAudioCheckBoxClick);
            // 
            // audioRecordBtn
            // 
            this.audioRecordBtn.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.audioRecordBtn.Location = new System.Drawing.Point(21, 219);
            this.audioRecordBtn.Name = "audioRecordBtn";
            this.audioRecordBtn.Size = new System.Drawing.Size(331, 32);
            this.audioRecordBtn.TabIndex = 42;
            this.audioRecordBtn.Text = "开启录音";
            this.audioRecordBtn.UseVisualStyleBackColor = true;
            this.audioRecordBtn.Click += new System.EventHandler(this.audioRecordBtn_Click);
            // 
            // roomLabel
            // 
            this.roomLabel.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.roomLabel.Location = new System.Drawing.Point(12, 268);
            this.roomLabel.Name = "roomLabel";
            this.roomLabel.Size = new System.Drawing.Size(92, 31);
            this.roomLabel.TabIndex = 43;
            this.roomLabel.Text = "房间(整型):";
            this.roomLabel.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // roomPanel
            // 
            this.roomPanel.BackColor = System.Drawing.Color.White;
            this.roomPanel.Controls.Add(this.roomIdTextBox);
            this.roomPanel.Location = new System.Drawing.Point(106, 267);
            this.roomPanel.Name = "roomPanel";
            this.roomPanel.Size = new System.Drawing.Size(258, 36);
            this.roomPanel.TabIndex = 44;
            // 
            // roomIdTextBox
            // 
            this.roomIdTextBox.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.roomIdTextBox.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.roomIdTextBox.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.roomIdTextBox.Location = new System.Drawing.Point(7, 8);
            this.roomIdTextBox.Margin = new System.Windows.Forms.Padding(0, 16, 3, 3);
            this.roomIdTextBox.MaxLength = 10;
            this.roomIdTextBox.Name = "roomIdTextBox";
            this.roomIdTextBox.Size = new System.Drawing.Size(242, 20);
            this.roomIdTextBox.TabIndex = 5;
            this.roomIdTextBox.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.OnRoomTextBoxKeyPress);
            // 
            // label2
            // 
            this.label2.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.label2.Location = new System.Drawing.Point(12, 310);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(92, 31);
            this.label2.TabIndex = 45;
            this.label2.Text = "房间(字符):";
            this.label2.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // panel2
            // 
            this.panel2.BackColor = System.Drawing.Color.White;
            this.panel2.Controls.Add(this.strRoomIdTextBox);
            this.panel2.Location = new System.Drawing.Point(106, 309);
            this.panel2.Name = "panel2";
            this.panel2.Size = new System.Drawing.Size(258, 36);
            this.panel2.TabIndex = 46;
            // 
            // strRoomIdTextBox
            // 
            this.strRoomIdTextBox.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.strRoomIdTextBox.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.strRoomIdTextBox.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.strRoomIdTextBox.Location = new System.Drawing.Point(7, 8);
            this.strRoomIdTextBox.Margin = new System.Windows.Forms.Padding(0, 16, 3, 3);
            this.strRoomIdTextBox.MaxLength = 10;
            this.strRoomIdTextBox.Name = "strRoomIdTextBox";
            this.strRoomIdTextBox.Size = new System.Drawing.Size(242, 20);
            this.strRoomIdTextBox.TabIndex = 5;
            // 
            // switchRoomBtn
            // 
            this.switchRoomBtn.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.switchRoomBtn.Location = new System.Drawing.Point(21, 351);
            this.switchRoomBtn.Name = "switchRoomBtn";
            this.switchRoomBtn.Size = new System.Drawing.Size(331, 32);
            this.switchRoomBtn.TabIndex = 47;
            this.switchRoomBtn.Text = "切换房间";
            this.switchRoomBtn.UseVisualStyleBackColor = true;
            this.switchRoomBtn.Click += new System.EventHandler(this.switchRoomBtn_Click);
            // 
            // label3
            // 
            this.label3.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.label3.Location = new System.Drawing.Point(12, 406);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(127, 31);
            this.label3.TabIndex = 45;
            this.label3.Text = "添加过滤窗口：";
            this.label3.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // panel3
            // 
            this.panel3.BackColor = System.Drawing.Color.White;
            this.panel3.Controls.Add(this.addHwndTextBox);
            this.panel3.Location = new System.Drawing.Point(140, 405);
            this.panel3.Name = "panel3";
            this.panel3.Size = new System.Drawing.Size(130, 36);
            this.panel3.TabIndex = 46;
            // 
            // addHwndTextBox
            // 
            this.addHwndTextBox.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.addHwndTextBox.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.addHwndTextBox.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.addHwndTextBox.Location = new System.Drawing.Point(5, 7);
            this.addHwndTextBox.Margin = new System.Windows.Forms.Padding(0, 16, 3, 3);
            this.addHwndTextBox.MaxLength = 10;
            this.addHwndTextBox.Name = "addHwndTextBox";
            this.addHwndTextBox.Size = new System.Drawing.Size(114, 20);
            this.addHwndTextBox.TabIndex = 5;
            // 
            // addHwndBtn
            // 
            this.addHwndBtn.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.addHwndBtn.Location = new System.Drawing.Point(276, 409);
            this.addHwndBtn.Name = "addHwndBtn";
            this.addHwndBtn.Size = new System.Drawing.Size(88, 32);
            this.addHwndBtn.TabIndex = 48;
            this.addHwndBtn.Text = "添加";
            this.addHwndBtn.UseVisualStyleBackColor = true;
            this.addHwndBtn.Click += new System.EventHandler(this.addHwndBtn_Click);
            // 
            // removeHwndBtn
            // 
            this.removeHwndBtn.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.removeHwndBtn.Location = new System.Drawing.Point(276, 451);
            this.removeHwndBtn.Name = "removeHwndBtn";
            this.removeHwndBtn.Size = new System.Drawing.Size(88, 32);
            this.removeHwndBtn.TabIndex = 51;
            this.removeHwndBtn.Text = "移除";
            this.removeHwndBtn.UseVisualStyleBackColor = true;
            this.removeHwndBtn.Click += new System.EventHandler(this.removeHwndBtn_Click);
            // 
            // label4
            // 
            this.label4.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.label4.Location = new System.Drawing.Point(12, 448);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(127, 31);
            this.label4.TabIndex = 49;
            this.label4.Text = "移除过滤窗口：";
            this.label4.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // panel4
            // 
            this.panel4.BackColor = System.Drawing.Color.White;
            this.panel4.Controls.Add(this.removeHwndTextBox);
            this.panel4.Location = new System.Drawing.Point(140, 447);
            this.panel4.Name = "panel4";
            this.panel4.Size = new System.Drawing.Size(130, 36);
            this.panel4.TabIndex = 50;
            // 
            // removeHwndTextBox
            // 
            this.removeHwndTextBox.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.removeHwndTextBox.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.removeHwndTextBox.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.removeHwndTextBox.Location = new System.Drawing.Point(5, 7);
            this.removeHwndTextBox.Margin = new System.Windows.Forms.Padding(0, 16, 3, 3);
            this.removeHwndTextBox.MaxLength = 10;
            this.removeHwndTextBox.Name = "removeHwndTextBox";
            this.removeHwndTextBox.Size = new System.Drawing.Size(114, 20);
            this.removeHwndTextBox.TabIndex = 5;
            // 
            // removeAllHwndBtn
            // 
            this.removeAllHwndBtn.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.removeAllHwndBtn.Location = new System.Drawing.Point(25, 489);
            this.removeAllHwndBtn.Name = "removeAllHwndBtn";
            this.removeAllHwndBtn.Size = new System.Drawing.Size(331, 32);
            this.removeAllHwndBtn.TabIndex = 52;
            this.removeAllHwndBtn.Text = "移除所有过滤窗口";
            this.removeAllHwndBtn.UseVisualStyleBackColor = true;
            this.removeAllHwndBtn.Click += new System.EventHandler(this.removeAllWindowsBtn_Click);
            // 
            // OtherSettingForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(96F, 96F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Dpi;
            this.BackColor = System.Drawing.Color.Gainsboro;
            this.ClientSize = new System.Drawing.Size(376, 562);
            this.Controls.Add(this.removeAllHwndBtn);
            this.Controls.Add(this.removeHwndBtn);
            this.Controls.Add(this.label4);
            this.Controls.Add(this.panel4);
            this.Controls.Add(this.addHwndBtn);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.switchRoomBtn);
            this.Controls.Add(this.panel3);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.panel2);
            this.Controls.Add(this.roomLabel);
            this.Controls.Add(this.roomPanel);
            this.Controls.Add(this.audioRecordBtn);
            this.Controls.Add(this.customVideoComboBox);
            this.Controls.Add(this.customAudioComboBox);
            this.Controls.Add(this.customVideoCheckBox);
            this.Controls.Add(this.customAudioCheckBox);
            this.Controls.Add(this.voiceCheckBox);
            this.Controls.Add(this.mirrorCheckBox);
            this.Controls.Add(this.panel1);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
            this.Name = "OtherSettingForm";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "OtherSettingForm";
            this.Load += new System.EventHandler(this.OnLoad);
            this.panel1.ResumeLayout(false);
            this.panel1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.exitPicBox)).EndInit();
            this.roomPanel.ResumeLayout(false);
            this.roomPanel.PerformLayout();
            this.panel2.ResumeLayout(false);
            this.panel2.PerformLayout();
            this.panel3.ResumeLayout(false);
            this.panel3.PerformLayout();
            this.panel4.ResumeLayout(false);
            this.panel4.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.PictureBox exitPicBox;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.CheckBox voiceCheckBox;
        private System.Windows.Forms.CheckBox mirrorCheckBox;
        private System.Windows.Forms.ComboBox customVideoComboBox;
        private System.Windows.Forms.ComboBox customAudioComboBox;
        private System.Windows.Forms.CheckBox customVideoCheckBox;
        private System.Windows.Forms.CheckBox customAudioCheckBox;
        private System.Windows.Forms.Button audioRecordBtn;
        private System.Windows.Forms.Label roomLabel;
        private System.Windows.Forms.Panel roomPanel;
        private System.Windows.Forms.TextBox roomIdTextBox;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Panel panel2;
        private System.Windows.Forms.TextBox strRoomIdTextBox;
        private System.Windows.Forms.Button switchRoomBtn;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Panel panel3;
        private System.Windows.Forms.TextBox addHwndTextBox;
        private System.Windows.Forms.Button addHwndBtn;
        private System.Windows.Forms.Button removeHwndBtn;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Panel panel4;
        private System.Windows.Forms.TextBox removeHwndTextBox;
        private System.Windows.Forms.Button removeAllHwndBtn;
    }
}