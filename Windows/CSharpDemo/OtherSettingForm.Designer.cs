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
            this.panel1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.exitPicBox)).BeginInit();
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
            this.voiceCheckBox.Location = new System.Drawing.Point(141, 90);
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
            this.mirrorCheckBox.Location = new System.Drawing.Point(21, 90);
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
            this.customVideoComboBox.Location = new System.Drawing.Point(176, 210);
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
            this.customAudioComboBox.Location = new System.Drawing.Point(176, 153);
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
            this.customVideoCheckBox.Location = new System.Drawing.Point(20, 210);
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
            this.customAudioCheckBox.Location = new System.Drawing.Point(20, 154);
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
            this.audioRecordBtn.Location = new System.Drawing.Point(21, 268);
            this.audioRecordBtn.Name = "audioRecordBtn";
            this.audioRecordBtn.Size = new System.Drawing.Size(331, 32);
            this.audioRecordBtn.TabIndex = 42;
            this.audioRecordBtn.Text = "开启录音";
            this.audioRecordBtn.UseVisualStyleBackColor = true;
            this.audioRecordBtn.Click += new System.EventHandler(this.audioRecordBtn_Click);
            // 
            // OtherSettingForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(96F, 96F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Dpi;
            this.BackColor = System.Drawing.Color.Gainsboro;
            this.ClientSize = new System.Drawing.Size(376, 349);
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
    }
}