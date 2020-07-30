namespace TRTCCSharpDemo
{
    partial class AudioSettingForm
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
            this.speakerProgressBar = new System.Windows.Forms.ProgressBar();
            this.micProgressBar = new System.Windows.Forms.ProgressBar();
            this.speakerTestBtn = new System.Windows.Forms.Button();
            this.micTestBtn = new System.Windows.Forms.Button();
            this.speakerVolumeNumLabel = new System.Windows.Forms.Label();
            this.speakerVolumeTrackBar = new System.Windows.Forms.TrackBar();
            this.speakerVolumeLabel = new System.Windows.Forms.Label();
            this.micVolumeNumLabel = new System.Windows.Forms.Label();
            this.micVolumeTrackBar = new System.Windows.Forms.TrackBar();
            this.micVolumeLabel = new System.Windows.Forms.Label();
            this.speakerDeviceComboBox = new System.Windows.Forms.ComboBox();
            this.speakerDeviceLabel = new System.Windows.Forms.Label();
            this.micDeviceComboBox = new System.Windows.Forms.ComboBox();
            this.micDeviceLabel = new System.Windows.Forms.Label();
            this.panel1 = new System.Windows.Forms.Panel();
            this.exitPicBox = new System.Windows.Forms.PictureBox();
            this.label1 = new System.Windows.Forms.Label();
            this.systemAudioCheckBox = new System.Windows.Forms.CheckBox();
            this.aecCheckBox = new System.Windows.Forms.CheckBox();
            this.ansCheckBox = new System.Windows.Forms.CheckBox();
            this.agcCheckBox = new System.Windows.Forms.CheckBox();
            this.label2 = new System.Windows.Forms.Label();
            this.audioQualityComboBox = new System.Windows.Forms.ComboBox();
            ((System.ComponentModel.ISupportInitialize)(this.speakerVolumeTrackBar)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.micVolumeTrackBar)).BeginInit();
            this.panel1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.exitPicBox)).BeginInit();
            this.SuspendLayout();
            // 
            // speakerProgressBar
            // 
            this.speakerProgressBar.Location = new System.Drawing.Point(182, 285);
            this.speakerProgressBar.Name = "speakerProgressBar";
            this.speakerProgressBar.Size = new System.Drawing.Size(213, 23);
            this.speakerProgressBar.TabIndex = 47;
            // 
            // micProgressBar
            // 
            this.micProgressBar.Location = new System.Drawing.Point(165, 144);
            this.micProgressBar.Name = "micProgressBar";
            this.micProgressBar.Size = new System.Drawing.Size(213, 23);
            this.micProgressBar.TabIndex = 46;
            // 
            // speakerTestBtn
            // 
            this.speakerTestBtn.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.speakerTestBtn.Location = new System.Drawing.Point(50, 280);
            this.speakerTestBtn.Name = "speakerTestBtn";
            this.speakerTestBtn.Size = new System.Drawing.Size(109, 32);
            this.speakerTestBtn.TabIndex = 45;
            this.speakerTestBtn.Text = "扬声器测试";
            this.speakerTestBtn.UseVisualStyleBackColor = true;
            this.speakerTestBtn.Click += new System.EventHandler(this.speakerTestBtn_Click);
            // 
            // micTestBtn
            // 
            this.micTestBtn.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.micTestBtn.Location = new System.Drawing.Point(50, 139);
            this.micTestBtn.Name = "micTestBtn";
            this.micTestBtn.Size = new System.Drawing.Size(109, 32);
            this.micTestBtn.TabIndex = 44;
            this.micTestBtn.Text = "麦克风测试";
            this.micTestBtn.UseVisualStyleBackColor = true;
            this.micTestBtn.Click += new System.EventHandler(this.micTestBtn_Click);
            // 
            // speakerVolumeNumLabel
            // 
            this.speakerVolumeNumLabel.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.speakerVolumeNumLabel.Location = new System.Drawing.Point(358, 237);
            this.speakerVolumeNumLabel.Name = "speakerVolumeNumLabel";
            this.speakerVolumeNumLabel.Size = new System.Drawing.Size(72, 28);
            this.speakerVolumeNumLabel.TabIndex = 43;
            this.speakerVolumeNumLabel.Text = "0%";
            this.speakerVolumeNumLabel.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // speakerVolumeTrackBar
            // 
            this.speakerVolumeTrackBar.AutoSize = false;
            this.speakerVolumeTrackBar.Cursor = System.Windows.Forms.Cursors.Hand;
            this.speakerVolumeTrackBar.Location = new System.Drawing.Point(126, 242);
            this.speakerVolumeTrackBar.Maximum = 100;
            this.speakerVolumeTrackBar.Name = "speakerVolumeTrackBar";
            this.speakerVolumeTrackBar.Size = new System.Drawing.Size(235, 28);
            this.speakerVolumeTrackBar.TabIndex = 42;
            this.speakerVolumeTrackBar.TickFrequency = 0;
            this.speakerVolumeTrackBar.TickStyle = System.Windows.Forms.TickStyle.None;
            this.speakerVolumeTrackBar.Scroll += new System.EventHandler(this.speakerVolumeTrackBar_Scroll);
            // 
            // speakerVolumeLabel
            // 
            this.speakerVolumeLabel.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.speakerVolumeLabel.Location = new System.Drawing.Point(30, 237);
            this.speakerVolumeLabel.Name = "speakerVolumeLabel";
            this.speakerVolumeLabel.Size = new System.Drawing.Size(106, 27);
            this.speakerVolumeLabel.TabIndex = 41;
            this.speakerVolumeLabel.Text = "音量：";
            this.speakerVolumeLabel.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // micVolumeNumLabel
            // 
            this.micVolumeNumLabel.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.micVolumeNumLabel.Location = new System.Drawing.Point(358, 106);
            this.micVolumeNumLabel.Name = "micVolumeNumLabel";
            this.micVolumeNumLabel.Size = new System.Drawing.Size(72, 28);
            this.micVolumeNumLabel.TabIndex = 40;
            this.micVolumeNumLabel.Text = "0%";
            this.micVolumeNumLabel.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // micVolumeTrackBar
            // 
            this.micVolumeTrackBar.AutoSize = false;
            this.micVolumeTrackBar.Cursor = System.Windows.Forms.Cursors.Hand;
            this.micVolumeTrackBar.Location = new System.Drawing.Point(132, 110);
            this.micVolumeTrackBar.Maximum = 100;
            this.micVolumeTrackBar.Name = "micVolumeTrackBar";
            this.micVolumeTrackBar.Size = new System.Drawing.Size(235, 28);
            this.micVolumeTrackBar.TabIndex = 39;
            this.micVolumeTrackBar.TickFrequency = 0;
            this.micVolumeTrackBar.TickStyle = System.Windows.Forms.TickStyle.None;
            this.micVolumeTrackBar.Scroll += new System.EventHandler(this.micVolumeTrackBar_Scroll);
            // 
            // micVolumeLabel
            // 
            this.micVolumeLabel.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.micVolumeLabel.Location = new System.Drawing.Point(30, 110);
            this.micVolumeLabel.Name = "micVolumeLabel";
            this.micVolumeLabel.Size = new System.Drawing.Size(106, 27);
            this.micVolumeLabel.TabIndex = 38;
            this.micVolumeLabel.Text = "音量：";
            this.micVolumeLabel.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // speakerDeviceComboBox
            // 
            this.speakerDeviceComboBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.speakerDeviceComboBox.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.speakerDeviceComboBox.FormattingEnabled = true;
            this.speakerDeviceComboBox.Location = new System.Drawing.Point(132, 201);
            this.speakerDeviceComboBox.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.speakerDeviceComboBox.Name = "speakerDeviceComboBox";
            this.speakerDeviceComboBox.Size = new System.Drawing.Size(282, 28);
            this.speakerDeviceComboBox.TabIndex = 37;
            this.speakerDeviceComboBox.SelectedIndexChanged += new System.EventHandler(this.speakerDeviceComboBox_SelectedIndexChanged);
            // 
            // speakerDeviceLabel
            // 
            this.speakerDeviceLabel.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.speakerDeviceLabel.Location = new System.Drawing.Point(46, 200);
            this.speakerDeviceLabel.Name = "speakerDeviceLabel";
            this.speakerDeviceLabel.Size = new System.Drawing.Size(92, 27);
            this.speakerDeviceLabel.TabIndex = 36;
            this.speakerDeviceLabel.Text = "扬声器：";
            this.speakerDeviceLabel.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // micDeviceComboBox
            // 
            this.micDeviceComboBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.micDeviceComboBox.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.micDeviceComboBox.FormattingEnabled = true;
            this.micDeviceComboBox.Location = new System.Drawing.Point(132, 74);
            this.micDeviceComboBox.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.micDeviceComboBox.Name = "micDeviceComboBox";
            this.micDeviceComboBox.Size = new System.Drawing.Size(282, 28);
            this.micDeviceComboBox.TabIndex = 35;
            this.micDeviceComboBox.SelectedIndexChanged += new System.EventHandler(this.micDeviceComboBox_SelectedIndexChanged);
            // 
            // micDeviceLabel
            // 
            this.micDeviceLabel.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.micDeviceLabel.Location = new System.Drawing.Point(46, 73);
            this.micDeviceLabel.Name = "micDeviceLabel";
            this.micDeviceLabel.Size = new System.Drawing.Size(92, 27);
            this.micDeviceLabel.TabIndex = 34;
            this.micDeviceLabel.Text = "麦克风：";
            this.micDeviceLabel.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // panel1
            // 
            this.panel1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(38)))), ((int)(((byte)(38)))), ((int)(((byte)(38)))));
            this.panel1.Controls.Add(this.exitPicBox);
            this.panel1.Controls.Add(this.label1);
            this.panel1.Location = new System.Drawing.Point(1, 0);
            this.panel1.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(519, 44);
            this.panel1.TabIndex = 48;
            this.panel1.MouseDown += new System.Windows.Forms.MouseEventHandler(this.OnFormMouseDown);
            this.panel1.MouseMove += new System.Windows.Forms.MouseEventHandler(this.OnFormMouseMove);
            this.panel1.MouseUp += new System.Windows.Forms.MouseEventHandler(this.OnFormMouseUp);
            // 
            // exitPicBox
            // 
            this.exitPicBox.BackgroundImage = global::TRTCCSharpDemo.Properties.Resources.close_white;
            this.exitPicBox.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Zoom;
            this.exitPicBox.Cursor = System.Windows.Forms.Cursors.Hand;
            this.exitPicBox.Location = new System.Drawing.Point(488, 12);
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
            this.label1.Text = "声音设置";
            // 
            // systemAudioCheckBox
            // 
            this.systemAudioCheckBox.AutoSize = true;
            this.systemAudioCheckBox.Font = new System.Drawing.Font("微软雅黑", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.systemAudioCheckBox.ForeColor = System.Drawing.SystemColors.ControlText;
            this.systemAudioCheckBox.Location = new System.Drawing.Point(71, 339);
            this.systemAudioCheckBox.Name = "systemAudioCheckBox";
            this.systemAudioCheckBox.Size = new System.Drawing.Size(93, 25);
            this.systemAudioCheckBox.TabIndex = 50;
            this.systemAudioCheckBox.Text = "系统混音";
            this.systemAudioCheckBox.UseVisualStyleBackColor = true;
            this.systemAudioCheckBox.Click += new System.EventHandler(this.OnSystemAudioCheckBoxClick);
            // 
            // aecCheckBox
            // 
            this.aecCheckBox.AutoSize = true;
            this.aecCheckBox.Font = new System.Drawing.Font("微软雅黑", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.aecCheckBox.ForeColor = System.Drawing.SystemColors.ControlText;
            this.aecCheckBox.Location = new System.Drawing.Point(182, 339);
            this.aecCheckBox.Name = "aecCheckBox";
            this.aecCheckBox.Size = new System.Drawing.Size(93, 25);
            this.aecCheckBox.TabIndex = 51;
            this.aecCheckBox.Text = "回声消除";
            this.aecCheckBox.UseVisualStyleBackColor = true;
            this.aecCheckBox.CheckedChanged += new System.EventHandler(this.aecCheckBox_CheckedChanged);
            // 
            // ansCheckBox
            // 
            this.ansCheckBox.AutoSize = true;
            this.ansCheckBox.Font = new System.Drawing.Font("微软雅黑", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.ansCheckBox.ForeColor = System.Drawing.SystemColors.ControlText;
            this.ansCheckBox.Location = new System.Drawing.Point(285, 339);
            this.ansCheckBox.Name = "ansCheckBox";
            this.ansCheckBox.Size = new System.Drawing.Size(93, 25);
            this.ansCheckBox.TabIndex = 52;
            this.ansCheckBox.Text = "采集降噪";
            this.ansCheckBox.UseVisualStyleBackColor = true;
            this.ansCheckBox.CheckedChanged += new System.EventHandler(this.ansCheckBox_CheckedChanged);
            // 
            // agcCheckBox
            // 
            this.agcCheckBox.AutoSize = true;
            this.agcCheckBox.Font = new System.Drawing.Font("微软雅黑", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.agcCheckBox.ForeColor = System.Drawing.SystemColors.ControlText;
            this.agcCheckBox.Location = new System.Drawing.Point(384, 339);
            this.agcCheckBox.Name = "agcCheckBox";
            this.agcCheckBox.Size = new System.Drawing.Size(93, 25);
            this.agcCheckBox.TabIndex = 53;
            this.agcCheckBox.Text = "自动增益";
            this.agcCheckBox.UseVisualStyleBackColor = true;
            this.agcCheckBox.CheckedChanged += new System.EventHandler(this.agcCheckBox_CheckedChanged);
            // 
            // label2
            // 
            this.label2.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.label2.Location = new System.Drawing.Point(30, 391);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(174, 27);
            this.label2.TabIndex = 54;
            this.label2.Text = "音质(重新进房生效):";
            this.label2.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // audioQualityComboBox
            // 
            this.audioQualityComboBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.audioQualityComboBox.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.audioQualityComboBox.FormattingEnabled = true;
            this.audioQualityComboBox.Location = new System.Drawing.Point(210, 390);
            this.audioQualityComboBox.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.audioQualityComboBox.Name = "audioQualityComboBox";
            this.audioQualityComboBox.Size = new System.Drawing.Size(185, 28);
            this.audioQualityComboBox.TabIndex = 55;
            this.audioQualityComboBox.SelectedIndexChanged += new System.EventHandler(this.audioQualityComboBox_SelectedIndexChanged);
            // 
            // AudioSettingForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(96F, 96F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Dpi;
            this.BackColor = System.Drawing.Color.Gainsboro;
            this.ClientSize = new System.Drawing.Size(522, 500);
            this.Controls.Add(this.audioQualityComboBox);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.agcCheckBox);
            this.Controls.Add(this.ansCheckBox);
            this.Controls.Add(this.aecCheckBox);
            this.Controls.Add(this.systemAudioCheckBox);
            this.Controls.Add(this.panel1);
            this.Controls.Add(this.speakerProgressBar);
            this.Controls.Add(this.micProgressBar);
            this.Controls.Add(this.speakerTestBtn);
            this.Controls.Add(this.micTestBtn);
            this.Controls.Add(this.speakerVolumeNumLabel);
            this.Controls.Add(this.speakerVolumeTrackBar);
            this.Controls.Add(this.speakerVolumeLabel);
            this.Controls.Add(this.micVolumeNumLabel);
            this.Controls.Add(this.micVolumeTrackBar);
            this.Controls.Add(this.micVolumeLabel);
            this.Controls.Add(this.speakerDeviceComboBox);
            this.Controls.Add(this.speakerDeviceLabel);
            this.Controls.Add(this.micDeviceComboBox);
            this.Controls.Add(this.micDeviceLabel);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
            this.Name = "AudioSettingForm";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "AudioSettingForm";
            this.Load += new System.EventHandler(this.OnLoad);
            ((System.ComponentModel.ISupportInitialize)(this.speakerVolumeTrackBar)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.micVolumeTrackBar)).EndInit();
            this.panel1.ResumeLayout(false);
            this.panel1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.exitPicBox)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.ProgressBar speakerProgressBar;
        private System.Windows.Forms.ProgressBar micProgressBar;
        private System.Windows.Forms.Button speakerTestBtn;
        private System.Windows.Forms.Button micTestBtn;
        private System.Windows.Forms.Label speakerVolumeNumLabel;
        private System.Windows.Forms.TrackBar speakerVolumeTrackBar;
        private System.Windows.Forms.Label speakerVolumeLabel;
        private System.Windows.Forms.Label micVolumeNumLabel;
        private System.Windows.Forms.TrackBar micVolumeTrackBar;
        private System.Windows.Forms.Label micVolumeLabel;
        private System.Windows.Forms.ComboBox speakerDeviceComboBox;
        private System.Windows.Forms.Label speakerDeviceLabel;
        private System.Windows.Forms.ComboBox micDeviceComboBox;
        private System.Windows.Forms.Label micDeviceLabel;
        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.PictureBox exitPicBox;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.CheckBox systemAudioCheckBox;
        private System.Windows.Forms.CheckBox aecCheckBox;
        private System.Windows.Forms.CheckBox ansCheckBox;
        private System.Windows.Forms.CheckBox agcCheckBox;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.ComboBox audioQualityComboBox;
    }
}