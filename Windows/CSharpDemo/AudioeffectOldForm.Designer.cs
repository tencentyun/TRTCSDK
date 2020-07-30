namespace TRTCCSharpDemo
{
    partial class AudioEffectOldForm
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(AudioEffectOldForm));
            this.label1 = new System.Windows.Forms.Label();
            this.panel1 = new System.Windows.Forms.Panel();
            this.exitPicBox = new System.Windows.Forms.PictureBox();
            this.bgmTestBtn = new System.Windows.Forms.Button();
            this.confirmBtn = new System.Windows.Forms.Button();
            this.audioEffectTestBtn = new System.Windows.Forms.Button();
            this.audioRecordBtn = new System.Windows.Forms.Button();
            this.panel1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.exitPicBox)).BeginInit();
            this.SuspendLayout();
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
            this.label1.Text = "背景音乐";
            // 
            // panel1
            // 
            this.panel1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(38)))), ((int)(((byte)(38)))), ((int)(((byte)(38)))));
            this.panel1.Controls.Add(this.exitPicBox);
            this.panel1.Controls.Add(this.label1);
            this.panel1.Location = new System.Drawing.Point(0, 0);
            this.panel1.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(397, 42);
            this.panel1.TabIndex = 2;
            this.panel1.MouseDown += new System.Windows.Forms.MouseEventHandler(this.OnFormMouseDown);
            this.panel1.MouseMove += new System.Windows.Forms.MouseEventHandler(this.OnFormMouseMove);
            this.panel1.MouseUp += new System.Windows.Forms.MouseEventHandler(this.OnFormMouseUp);
            // 
            // exitPicBox
            // 
            this.exitPicBox.BackgroundImage = global::TRTCCSharpDemo.Properties.Resources.close_white;
            this.exitPicBox.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Zoom;
            this.exitPicBox.Cursor = System.Windows.Forms.Cursors.Hand;
            this.exitPicBox.Location = new System.Drawing.Point(363, 8);
            this.exitPicBox.Name = "exitPicBox";
            this.exitPicBox.Size = new System.Drawing.Size(25, 25);
            this.exitPicBox.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.exitPicBox.TabIndex = 31;
            this.exitPicBox.TabStop = false;
            this.exitPicBox.Click += new System.EventHandler(this.OnExitPicBoxClick);
            // 
            // bgmTestBtn
            // 
            this.bgmTestBtn.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.bgmTestBtn.Location = new System.Drawing.Point(28, 89);
            this.bgmTestBtn.Name = "bgmTestBtn";
            this.bgmTestBtn.Size = new System.Drawing.Size(331, 32);
            this.bgmTestBtn.TabIndex = 5;
            this.bgmTestBtn.Text = "启动BGM测试";
            this.bgmTestBtn.UseVisualStyleBackColor = true;
            this.bgmTestBtn.Click += new System.EventHandler(this.OnBGMTestBtnClick);
            // 
            // confirmBtn
            // 
            this.confirmBtn.Anchor = System.Windows.Forms.AnchorStyles.Bottom;
            this.confirmBtn.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.confirmBtn.Location = new System.Drawing.Point(138, 239);
            this.confirmBtn.Name = "confirmBtn";
            this.confirmBtn.Size = new System.Drawing.Size(104, 36);
            this.confirmBtn.TabIndex = 17;
            this.confirmBtn.Text = "确定";
            this.confirmBtn.UseVisualStyleBackColor = true;
            this.confirmBtn.Click += new System.EventHandler(this.OnConfirmBtnClick);
            // 
            // audioEffectTestBtn
            // 
            this.audioEffectTestBtn.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.audioEffectTestBtn.Location = new System.Drawing.Point(29, 133);
            this.audioEffectTestBtn.Name = "audioEffectTestBtn";
            this.audioEffectTestBtn.Size = new System.Drawing.Size(331, 32);
            this.audioEffectTestBtn.TabIndex = 20;
            this.audioEffectTestBtn.Text = "启动音效测试";
            this.audioEffectTestBtn.UseVisualStyleBackColor = true;
            this.audioEffectTestBtn.Click += new System.EventHandler(this.OnAudioTestBtnClick);
            // 
            // audioRecordBtn
            // 
            this.audioRecordBtn.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.audioRecordBtn.Location = new System.Drawing.Point(29, 176);
            this.audioRecordBtn.Name = "audioRecordBtn";
            this.audioRecordBtn.Size = new System.Drawing.Size(331, 32);
            this.audioRecordBtn.TabIndex = 21;
            this.audioRecordBtn.Text = "开启录音";
            this.audioRecordBtn.UseVisualStyleBackColor = true;
            this.audioRecordBtn.Click += new System.EventHandler(this.OnAudioRecordBtnClick);
            // 
            // AudioeffectOldForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(96F, 96F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Dpi;
            this.BackColor = System.Drawing.Color.Gainsboro;
            this.ClientSize = new System.Drawing.Size(397, 305);
            this.Controls.Add(this.audioRecordBtn);
            this.Controls.Add(this.audioEffectTestBtn);
            this.Controls.Add(this.confirmBtn);
            this.Controls.Add(this.bgmTestBtn);
            this.Controls.Add(this.panel1);
            this.DoubleBuffered = true;
            this.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.Name = "AudioeffectOldForm";
            this.ShowInTaskbar = false;
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "TRTCDeviceTestForm";
            this.panel1.ResumeLayout(false);
            this.panel1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.exitPicBox)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.Button bgmTestBtn;
        private System.Windows.Forms.Button confirmBtn;
        private System.Windows.Forms.PictureBox exitPicBox;
        private System.Windows.Forms.Button audioEffectTestBtn;
        private System.Windows.Forms.Button audioRecordBtn;
    }
}