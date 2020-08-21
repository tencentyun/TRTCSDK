namespace TRTCCSharpDemo
{
    partial class AudioEffectForm
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(AudioEffectForm));
            this.panel1 = new System.Windows.Forms.Panel();
            this.exitPicBox = new System.Windows.Forms.PictureBox();
            this.label1 = new System.Windows.Forms.Label();
            this.bgmPlayBtn = new System.Windows.Forms.Button();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.BGMPitchTrackBar = new System.Windows.Forms.TrackBar();
            this.BGMSpeedTrackBar = new System.Windows.Forms.TrackBar();
            this.label6 = new System.Windows.Forms.Label();
            this.label5 = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.RemoteVolumTrackBar = new System.Windows.Forms.TrackBar();
            this.LocalVolumTrackBar = new System.Windows.Forms.TrackBar();
            this.BGMVolumTrackBar = new System.Windows.Forms.TrackBar();
            this.bgmTimeLabel = new System.Windows.Forms.Label();
            this.BGMprogressBar = new System.Windows.Forms.ProgressBar();
            this.bgmStopBtn = new System.Windows.Forms.Button();
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.effect3PublishCheckBox = new System.Windows.Forms.CheckBox();
            this.effect2PublishCheckBox = new System.Windows.Forms.CheckBox();
            this.effect1PublishCheckBox = new System.Windows.Forms.CheckBox();
            this.effect3CycleCheckBox = new System.Windows.Forms.CheckBox();
            this.effect2CycleCheckBox = new System.Windows.Forms.CheckBox();
            this.effect1CycleCheckBox = new System.Windows.Forms.CheckBox();
            this.effect3CheckBox = new System.Windows.Forms.CheckBox();
            this.effect2CheckBox = new System.Windows.Forms.CheckBox();
            this.effect1CheckBox = new System.Windows.Forms.CheckBox();
            this.panel1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.exitPicBox)).BeginInit();
            this.groupBox1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.BGMPitchTrackBar)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.BGMSpeedTrackBar)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.RemoteVolumTrackBar)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.LocalVolumTrackBar)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.BGMVolumTrackBar)).BeginInit();
            this.groupBox2.SuspendLayout();
            this.SuspendLayout();
            // 
            // panel1
            // 
            this.panel1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(38)))), ((int)(((byte)(38)))), ((int)(((byte)(38)))));
            this.panel1.Controls.Add(this.exitPicBox);
            this.panel1.Controls.Add(this.label1);
            this.panel1.Location = new System.Drawing.Point(2, 3);
            this.panel1.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(419, 36);
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
            this.exitPicBox.Location = new System.Drawing.Point(386, 7);
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
            this.label1.Location = new System.Drawing.Point(3, 7);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(74, 21);
            this.label1.TabIndex = 0;
            this.label1.Text = "背景音乐";
            // 
            // bgmPlayBtn
            // 
            this.bgmPlayBtn.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.bgmPlayBtn.Location = new System.Drawing.Point(20, 34);
            this.bgmPlayBtn.Name = "bgmPlayBtn";
            this.bgmPlayBtn.Size = new System.Drawing.Size(86, 32);
            this.bgmPlayBtn.TabIndex = 6;
            this.bgmPlayBtn.Text = "播放";
            this.bgmPlayBtn.UseVisualStyleBackColor = true;
            this.bgmPlayBtn.Click += new System.EventHandler(this.bgmPlayBtn_Click);
            // 
            // groupBox1
            // 
            this.groupBox1.BackColor = System.Drawing.Color.Gainsboro;
            this.groupBox1.Controls.Add(this.BGMPitchTrackBar);
            this.groupBox1.Controls.Add(this.BGMSpeedTrackBar);
            this.groupBox1.Controls.Add(this.label6);
            this.groupBox1.Controls.Add(this.label5);
            this.groupBox1.Controls.Add(this.label4);
            this.groupBox1.Controls.Add(this.label3);
            this.groupBox1.Controls.Add(this.label2);
            this.groupBox1.Controls.Add(this.RemoteVolumTrackBar);
            this.groupBox1.Controls.Add(this.LocalVolumTrackBar);
            this.groupBox1.Controls.Add(this.BGMVolumTrackBar);
            this.groupBox1.Controls.Add(this.bgmTimeLabel);
            this.groupBox1.Controls.Add(this.BGMprogressBar);
            this.groupBox1.Controls.Add(this.bgmStopBtn);
            this.groupBox1.Controls.Add(this.bgmPlayBtn);
            this.groupBox1.Location = new System.Drawing.Point(9, 46);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(399, 332);
            this.groupBox1.TabIndex = 7;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "BGM";
            // 
            // BGMPitchTrackBar
            // 
            this.BGMPitchTrackBar.AutoSize = false;
            this.BGMPitchTrackBar.Location = new System.Drawing.Point(102, 288);
            this.BGMPitchTrackBar.Maximum = 1500;
            this.BGMPitchTrackBar.Minimum = 200;
            this.BGMPitchTrackBar.Name = "BGMPitchTrackBar";
            this.BGMPitchTrackBar.Size = new System.Drawing.Size(195, 25);
            this.BGMPitchTrackBar.TabIndex = 46;
            this.BGMPitchTrackBar.TickFrequency = 0;
            this.BGMPitchTrackBar.TickStyle = System.Windows.Forms.TickStyle.None;
            this.BGMPitchTrackBar.Value = 500;
            this.BGMPitchTrackBar.Scroll += new System.EventHandler(this.bgmPitchTrackBar_Scroll);
            // 
            // BGMSpeedTrackBar
            // 
            this.BGMSpeedTrackBar.AutoSize = false;
            this.BGMSpeedTrackBar.Location = new System.Drawing.Point(102, 252);
            this.BGMSpeedTrackBar.Maximum = 1500;
            this.BGMSpeedTrackBar.Minimum = 200;
            this.BGMSpeedTrackBar.Name = "BGMSpeedTrackBar";
            this.BGMSpeedTrackBar.Size = new System.Drawing.Size(195, 25);
            this.BGMSpeedTrackBar.TabIndex = 45;
            this.BGMSpeedTrackBar.TickFrequency = 0;
            this.BGMSpeedTrackBar.TickStyle = System.Windows.Forms.TickStyle.None;
            this.BGMSpeedTrackBar.Value = 500;
            this.BGMSpeedTrackBar.Scroll += new System.EventHandler(this.bgmSpeedTrackBar_Scroll);
            // 
            // label6
            // 
            this.label6.Font = new System.Drawing.Font("微软雅黑", 10.5F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.label6.Location = new System.Drawing.Point(16, 251);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(89, 27);
            this.label6.TabIndex = 44;
            this.label6.Text = "播放速度：";
            this.label6.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label5
            // 
            this.label5.Font = new System.Drawing.Font("微软雅黑", 10.5F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.label5.Location = new System.Drawing.Point(16, 287);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(89, 27);
            this.label5.TabIndex = 43;
            this.label5.Text = "播放音调：";
            this.label5.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label4
            // 
            this.label4.Font = new System.Drawing.Font("微软雅黑", 10.5F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.label4.Location = new System.Drawing.Point(16, 215);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(89, 27);
            this.label4.TabIndex = 42;
            this.label4.Text = "远端音量：";
            this.label4.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label3
            // 
            this.label3.Font = new System.Drawing.Font("微软雅黑", 10.5F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.label3.Location = new System.Drawing.Point(16, 179);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(89, 27);
            this.label3.TabIndex = 41;
            this.label3.Text = "本地音量：";
            this.label3.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label2
            // 
            this.label2.Font = new System.Drawing.Font("微软雅黑", 10.5F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.label2.Location = new System.Drawing.Point(16, 143);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(89, 27);
            this.label2.TabIndex = 40;
            this.label2.Text = "BGM音量：";
            this.label2.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // RemoteVolumTrackBar
            // 
            this.RemoteVolumTrackBar.AutoSize = false;
            this.RemoteVolumTrackBar.Location = new System.Drawing.Point(102, 216);
            this.RemoteVolumTrackBar.Maximum = 1500;
            this.RemoteVolumTrackBar.Minimum = 200;
            this.RemoteVolumTrackBar.Name = "RemoteVolumTrackBar";
            this.RemoteVolumTrackBar.Size = new System.Drawing.Size(195, 25);
            this.RemoteVolumTrackBar.TabIndex = 38;
            this.RemoteVolumTrackBar.TickFrequency = 0;
            this.RemoteVolumTrackBar.TickStyle = System.Windows.Forms.TickStyle.None;
            this.RemoteVolumTrackBar.Value = 500;
            this.RemoteVolumTrackBar.Scroll += new System.EventHandler(this.RemoteVolumTrackBar_Scroll);
            // 
            // LocalVolumTrackBar
            // 
            this.LocalVolumTrackBar.AutoSize = false;
            this.LocalVolumTrackBar.Location = new System.Drawing.Point(102, 180);
            this.LocalVolumTrackBar.Maximum = 1500;
            this.LocalVolumTrackBar.Minimum = 200;
            this.LocalVolumTrackBar.Name = "LocalVolumTrackBar";
            this.LocalVolumTrackBar.Size = new System.Drawing.Size(195, 25);
            this.LocalVolumTrackBar.TabIndex = 37;
            this.LocalVolumTrackBar.TickFrequency = 0;
            this.LocalVolumTrackBar.TickStyle = System.Windows.Forms.TickStyle.None;
            this.LocalVolumTrackBar.Value = 500;
            this.LocalVolumTrackBar.Scroll += new System.EventHandler(this.LocalVolumTrackBar_Scroll);
            // 
            // BGMVolumTrackBar
            // 
            this.BGMVolumTrackBar.AutoSize = false;
            this.BGMVolumTrackBar.Location = new System.Drawing.Point(102, 144);
            this.BGMVolumTrackBar.Maximum = 1500;
            this.BGMVolumTrackBar.Minimum = 200;
            this.BGMVolumTrackBar.Name = "BGMVolumTrackBar";
            this.BGMVolumTrackBar.Size = new System.Drawing.Size(195, 25);
            this.BGMVolumTrackBar.TabIndex = 36;
            this.BGMVolumTrackBar.TickFrequency = 0;
            this.BGMVolumTrackBar.TickStyle = System.Windows.Forms.TickStyle.None;
            this.BGMVolumTrackBar.Value = 500;
            this.BGMVolumTrackBar.Scroll += new System.EventHandler(this.BGMVolumTrackBar_Scroll);
            // 
            // bgmTimeLabel
            // 
            this.bgmTimeLabel.Font = new System.Drawing.Font("微软雅黑", 10.5F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.bgmTimeLabel.Location = new System.Drawing.Point(278, 94);
            this.bgmTimeLabel.Name = "bgmTimeLabel";
            this.bgmTimeLabel.Size = new System.Drawing.Size(115, 27);
            this.bgmTimeLabel.TabIndex = 35;
            this.bgmTimeLabel.Text = "00:00/00:00";
            this.bgmTimeLabel.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // BGMprogressBar
            // 
            this.BGMprogressBar.Location = new System.Drawing.Point(20, 94);
            this.BGMprogressBar.Name = "BGMprogressBar";
            this.BGMprogressBar.Size = new System.Drawing.Size(252, 23);
            this.BGMprogressBar.TabIndex = 8;
            // 
            // bgmStopBtn
            // 
            this.bgmStopBtn.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.bgmStopBtn.Location = new System.Drawing.Point(127, 34);
            this.bgmStopBtn.Name = "bgmStopBtn";
            this.bgmStopBtn.Size = new System.Drawing.Size(86, 32);
            this.bgmStopBtn.TabIndex = 7;
            this.bgmStopBtn.Text = "停止";
            this.bgmStopBtn.UseVisualStyleBackColor = true;
            this.bgmStopBtn.Click += new System.EventHandler(this.bgmStopBtn_Click);
            // 
            // groupBox2
            // 
            this.groupBox2.BackColor = System.Drawing.Color.Gainsboro;
            this.groupBox2.Controls.Add(this.effect3PublishCheckBox);
            this.groupBox2.Controls.Add(this.effect2PublishCheckBox);
            this.groupBox2.Controls.Add(this.effect1PublishCheckBox);
            this.groupBox2.Controls.Add(this.effect3CycleCheckBox);
            this.groupBox2.Controls.Add(this.effect2CycleCheckBox);
            this.groupBox2.Controls.Add(this.effect1CycleCheckBox);
            this.groupBox2.Controls.Add(this.effect3CheckBox);
            this.groupBox2.Controls.Add(this.effect2CheckBox);
            this.groupBox2.Controls.Add(this.effect1CheckBox);
            this.groupBox2.Location = new System.Drawing.Point(9, 384);
            this.groupBox2.Name = "groupBox2";
            this.groupBox2.Size = new System.Drawing.Size(399, 165);
            this.groupBox2.TabIndex = 8;
            this.groupBox2.TabStop = false;
            this.groupBox2.Text = "音效";
            // 
            // effect3PublishCheckBox
            // 
            this.effect3PublishCheckBox.AutoSize = true;
            this.effect3PublishCheckBox.CheckAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.effect3PublishCheckBox.Location = new System.Drawing.Point(258, 113);
            this.effect3PublishCheckBox.Name = "effect3PublishCheckBox";
            this.effect3PublishCheckBox.Size = new System.Drawing.Size(75, 21);
            this.effect3PublishCheckBox.TabIndex = 8;
            this.effect3PublishCheckBox.Text = "推送远端";
            this.effect3PublishCheckBox.UseVisualStyleBackColor = true;
            this.effect3PublishCheckBox.CheckedChanged += new System.EventHandler(this.effect3PublishCheckBox_CheckedChanged);
            // 
            // effect2PublishCheckBox
            // 
            this.effect2PublishCheckBox.AutoSize = true;
            this.effect2PublishCheckBox.CheckAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.effect2PublishCheckBox.Location = new System.Drawing.Point(258, 73);
            this.effect2PublishCheckBox.Name = "effect2PublishCheckBox";
            this.effect2PublishCheckBox.Size = new System.Drawing.Size(75, 21);
            this.effect2PublishCheckBox.TabIndex = 7;
            this.effect2PublishCheckBox.Text = "推送远端";
            this.effect2PublishCheckBox.UseVisualStyleBackColor = true;
            this.effect2PublishCheckBox.CheckedChanged += new System.EventHandler(this.effect2PublishCheckBox_CheckedChanged);
            // 
            // effect1PublishCheckBox
            // 
            this.effect1PublishCheckBox.AutoSize = true;
            this.effect1PublishCheckBox.CheckAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.effect1PublishCheckBox.Location = new System.Drawing.Point(258, 33);
            this.effect1PublishCheckBox.Name = "effect1PublishCheckBox";
            this.effect1PublishCheckBox.Size = new System.Drawing.Size(75, 21);
            this.effect1PublishCheckBox.TabIndex = 6;
            this.effect1PublishCheckBox.Text = "推送远端";
            this.effect1PublishCheckBox.UseVisualStyleBackColor = true;
            this.effect1PublishCheckBox.CheckedChanged += new System.EventHandler(this.effect1PublishCheckBox_CheckedChanged);
            // 
            // effect3CycleCheckBox
            // 
            this.effect3CycleCheckBox.AutoSize = true;
            this.effect3CycleCheckBox.CheckAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.effect3CycleCheckBox.Location = new System.Drawing.Point(141, 113);
            this.effect3CycleCheckBox.Name = "effect3CycleCheckBox";
            this.effect3CycleCheckBox.Size = new System.Drawing.Size(51, 21);
            this.effect3CycleCheckBox.TabIndex = 5;
            this.effect3CycleCheckBox.Text = "循环";
            this.effect3CycleCheckBox.UseVisualStyleBackColor = true;
            this.effect3CycleCheckBox.CheckedChanged += new System.EventHandler(this.effect3CycleCheckBox_CheckedChanged);
            // 
            // effect2CycleCheckBox
            // 
            this.effect2CycleCheckBox.AutoSize = true;
            this.effect2CycleCheckBox.CheckAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.effect2CycleCheckBox.Location = new System.Drawing.Point(141, 73);
            this.effect2CycleCheckBox.Name = "effect2CycleCheckBox";
            this.effect2CycleCheckBox.Size = new System.Drawing.Size(51, 21);
            this.effect2CycleCheckBox.TabIndex = 4;
            this.effect2CycleCheckBox.Text = "循环";
            this.effect2CycleCheckBox.UseVisualStyleBackColor = true;
            this.effect2CycleCheckBox.CheckedChanged += new System.EventHandler(this.effect2CycleCheckBox_CheckedChanged);
            // 
            // effect1CycleCheckBox
            // 
            this.effect1CycleCheckBox.AutoSize = true;
            this.effect1CycleCheckBox.CheckAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.effect1CycleCheckBox.Location = new System.Drawing.Point(141, 33);
            this.effect1CycleCheckBox.Name = "effect1CycleCheckBox";
            this.effect1CycleCheckBox.Size = new System.Drawing.Size(51, 21);
            this.effect1CycleCheckBox.TabIndex = 3;
            this.effect1CycleCheckBox.Text = "循环";
            this.effect1CycleCheckBox.UseVisualStyleBackColor = true;
            this.effect1CycleCheckBox.CheckedChanged += new System.EventHandler(this.effect1CycleCheckBox_CheckedChanged);
            // 
            // effect3CheckBox
            // 
            this.effect3CheckBox.AutoSize = true;
            this.effect3CheckBox.CheckAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.effect3CheckBox.Location = new System.Drawing.Point(20, 113);
            this.effect3CheckBox.Name = "effect3CheckBox";
            this.effect3CheckBox.Size = new System.Drawing.Size(58, 21);
            this.effect3CheckBox.TabIndex = 2;
            this.effect3CheckBox.Text = "音效3";
            this.effect3CheckBox.UseVisualStyleBackColor = true;
            this.effect3CheckBox.CheckedChanged += new System.EventHandler(this.effect3CheckBox_CheckedChanged);
            // 
            // effect2CheckBox
            // 
            this.effect2CheckBox.AutoSize = true;
            this.effect2CheckBox.CheckAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.effect2CheckBox.Location = new System.Drawing.Point(21, 73);
            this.effect2CheckBox.Name = "effect2CheckBox";
            this.effect2CheckBox.Size = new System.Drawing.Size(58, 21);
            this.effect2CheckBox.TabIndex = 1;
            this.effect2CheckBox.Text = "音效2";
            this.effect2CheckBox.UseVisualStyleBackColor = true;
            this.effect2CheckBox.CheckedChanged += new System.EventHandler(this.effect2CheckBox_CheckedChanged);
            // 
            // effect1CheckBox
            // 
            this.effect1CheckBox.AutoSize = true;
            this.effect1CheckBox.CheckAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.effect1CheckBox.Location = new System.Drawing.Point(20, 33);
            this.effect1CheckBox.Name = "effect1CheckBox";
            this.effect1CheckBox.Size = new System.Drawing.Size(58, 21);
            this.effect1CheckBox.TabIndex = 0;
            this.effect1CheckBox.Text = "音效1";
            this.effect1CheckBox.UseVisualStyleBackColor = true;
            this.effect1CheckBox.CheckedChanged += new System.EventHandler(this.effect1CheckBox_CheckedChanged);
            // 
            // AudioEffectForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(96F, 96F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Dpi;
            this.BackColor = System.Drawing.Color.WhiteSmoke;
            this.ClientSize = new System.Drawing.Size(423, 561);
            this.Controls.Add(this.groupBox2);
            this.Controls.Add(this.groupBox1);
            this.Controls.Add(this.panel1);
            this.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Name = "AudioEffectForm";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "AudioeffectForm";
            this.panel1.ResumeLayout(false);
            this.panel1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.exitPicBox)).EndInit();
            this.groupBox1.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.BGMPitchTrackBar)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.BGMSpeedTrackBar)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.RemoteVolumTrackBar)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.LocalVolumTrackBar)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.BGMVolumTrackBar)).EndInit();
            this.groupBox2.ResumeLayout(false);
            this.groupBox2.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.PictureBox exitPicBox;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Button bgmPlayBtn;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.Button bgmStopBtn;
        private System.Windows.Forms.GroupBox groupBox2;
        private System.Windows.Forms.ProgressBar BGMprogressBar;
        private System.Windows.Forms.Label bgmTimeLabel;
        private System.Windows.Forms.TrackBar RemoteVolumTrackBar;
        private System.Windows.Forms.TrackBar LocalVolumTrackBar;
        private System.Windows.Forms.TrackBar BGMVolumTrackBar;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.CheckBox effect3PublishCheckBox;
        private System.Windows.Forms.CheckBox effect2PublishCheckBox;
        private System.Windows.Forms.CheckBox effect1PublishCheckBox;
        private System.Windows.Forms.CheckBox effect3CycleCheckBox;
        private System.Windows.Forms.CheckBox effect2CycleCheckBox;
        private System.Windows.Forms.CheckBox effect1CycleCheckBox;
        private System.Windows.Forms.CheckBox effect3CheckBox;
        private System.Windows.Forms.CheckBox effect2CheckBox;
        private System.Windows.Forms.CheckBox effect1CheckBox;
        private System.Windows.Forms.TrackBar BGMPitchTrackBar;
        private System.Windows.Forms.TrackBar BGMSpeedTrackBar;
        private System.Windows.Forms.Label label6;
        private System.Windows.Forms.Label label5;
    }
}