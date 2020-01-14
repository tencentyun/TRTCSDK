namespace TRTCCSharpDemo
{
    partial class TRTCDeviceForm
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
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(TRTCDeviceForm));
            this.panel1 = new System.Windows.Forms.Panel();
            this.exitPicBox = new System.Windows.Forms.PictureBox();
            this.label1 = new System.Windows.Forms.Label();
            this.confirmBtn = new System.Windows.Forms.Button();
            this.cameraDeviceComboBox = new System.Windows.Forms.ComboBox();
            this.cameraDeviceLabel = new System.Windows.Forms.Label();
            this.micDeviceComboBox = new System.Windows.Forms.ComboBox();
            this.micDeviceLabel = new System.Windows.Forms.Label();
            this.speakerDeviceComboBox = new System.Windows.Forms.ComboBox();
            this.speakerDeviceLabel = new System.Windows.Forms.Label();
            this.micVolumeLabel = new System.Windows.Forms.Label();
            this.micVolumeTrackBar = new System.Windows.Forms.TrackBar();
            this.micVolumeNumLabel = new System.Windows.Forms.Label();
            this.speakerVolumeNumLabel = new System.Windows.Forms.Label();
            this.speakerVolumeTrackBar = new System.Windows.Forms.TrackBar();
            this.speakerVolumeLabel = new System.Windows.Forms.Label();
            this.panel1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.exitPicBox)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.micVolumeTrackBar)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.speakerVolumeTrackBar)).BeginInit();
            this.SuspendLayout();
            // 
            // panel1
            // 
            this.panel1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(38)))), ((int)(((byte)(38)))), ((int)(((byte)(38)))));
            this.panel1.Controls.Add(this.exitPicBox);
            this.panel1.Controls.Add(this.label1);
            this.panel1.Location = new System.Drawing.Point(0, 0);
            this.panel1.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(431, 42);
            this.panel1.TabIndex = 1;
            this.panel1.MouseDown += new System.Windows.Forms.MouseEventHandler(this.OnFormMouseDown);
            this.panel1.MouseMove += new System.Windows.Forms.MouseEventHandler(this.OnFormMouseMove);
            this.panel1.MouseUp += new System.Windows.Forms.MouseEventHandler(this.OnFormMouseUp);
            // 
            // exitPicBox
            // 
            this.exitPicBox.BackgroundImage = global::TRTCCSharpDemo.Properties.Resources.close_white;
            this.exitPicBox.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Zoom;
            this.exitPicBox.Cursor = System.Windows.Forms.Cursors.Hand;
            this.exitPicBox.Location = new System.Drawing.Point(397, 9);
            this.exitPicBox.Name = "exitPicBox";
            this.exitPicBox.Size = new System.Drawing.Size(25, 25);
            this.exitPicBox.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.exitPicBox.TabIndex = 30;
            this.exitPicBox.TabStop = false;
            this.exitPicBox.Click += new System.EventHandler(this.OnExitPicBoxClick);
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
            this.label1.Text = "设备选择";
            // 
            // confirmBtn
            // 
            this.confirmBtn.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.confirmBtn.Location = new System.Drawing.Point(161, 267);
            this.confirmBtn.Name = "confirmBtn";
            this.confirmBtn.Size = new System.Drawing.Size(104, 36);
            this.confirmBtn.TabIndex = 16;
            this.confirmBtn.Text = "确定";
            this.confirmBtn.UseVisualStyleBackColor = true;
            this.confirmBtn.Click += new System.EventHandler(this.OnConfirmBtnClick);
            // 
            // cameraDeviceComboBox
            // 
            this.cameraDeviceComboBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cameraDeviceComboBox.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.cameraDeviceComboBox.FormattingEnabled = true;
            this.cameraDeviceComboBox.Location = new System.Drawing.Point(106, 70);
            this.cameraDeviceComboBox.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.cameraDeviceComboBox.Name = "cameraDeviceComboBox";
            this.cameraDeviceComboBox.Size = new System.Drawing.Size(282, 28);
            this.cameraDeviceComboBox.TabIndex = 19;
            this.cameraDeviceComboBox.SelectedIndexChanged += new System.EventHandler(this.OnCameraDeviceComboBoxSelectedIndexChanged);
            // 
            // cameraDeviceLabel
            // 
            this.cameraDeviceLabel.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.cameraDeviceLabel.Location = new System.Drawing.Point(16, 69);
            this.cameraDeviceLabel.Name = "cameraDeviceLabel";
            this.cameraDeviceLabel.Size = new System.Drawing.Size(96, 27);
            this.cameraDeviceLabel.TabIndex = 18;
            this.cameraDeviceLabel.Text = "摄像头：";
            this.cameraDeviceLabel.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // micDeviceComboBox
            // 
            this.micDeviceComboBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.micDeviceComboBox.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.micDeviceComboBox.FormattingEnabled = true;
            this.micDeviceComboBox.Location = new System.Drawing.Point(106, 118);
            this.micDeviceComboBox.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.micDeviceComboBox.Name = "micDeviceComboBox";
            this.micDeviceComboBox.Size = new System.Drawing.Size(282, 28);
            this.micDeviceComboBox.TabIndex = 21;
            this.micDeviceComboBox.SelectedIndexChanged += new System.EventHandler(this.OnMicDeviceComboBoxSelectedIndexChanged);
            // 
            // micDeviceLabel
            // 
            this.micDeviceLabel.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.micDeviceLabel.Location = new System.Drawing.Point(20, 117);
            this.micDeviceLabel.Name = "micDeviceLabel";
            this.micDeviceLabel.Size = new System.Drawing.Size(92, 27);
            this.micDeviceLabel.TabIndex = 20;
            this.micDeviceLabel.Text = "麦克风：";
            this.micDeviceLabel.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // speakerDeviceComboBox
            // 
            this.speakerDeviceComboBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.speakerDeviceComboBox.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.speakerDeviceComboBox.FormattingEnabled = true;
            this.speakerDeviceComboBox.Location = new System.Drawing.Point(106, 191);
            this.speakerDeviceComboBox.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.speakerDeviceComboBox.Name = "speakerDeviceComboBox";
            this.speakerDeviceComboBox.Size = new System.Drawing.Size(282, 28);
            this.speakerDeviceComboBox.TabIndex = 23;
            this.speakerDeviceComboBox.SelectedIndexChanged += new System.EventHandler(this.OnSpeakerDeviceComboBoxSelectedIndexChanged);
            // 
            // speakerDeviceLabel
            // 
            this.speakerDeviceLabel.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.speakerDeviceLabel.Location = new System.Drawing.Point(20, 190);
            this.speakerDeviceLabel.Name = "speakerDeviceLabel";
            this.speakerDeviceLabel.Size = new System.Drawing.Size(92, 27);
            this.speakerDeviceLabel.TabIndex = 22;
            this.speakerDeviceLabel.Text = "扬声器：";
            this.speakerDeviceLabel.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // micVolumeLabel
            // 
            this.micVolumeLabel.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.micVolumeLabel.Location = new System.Drawing.Point(4, 154);
            this.micVolumeLabel.Name = "micVolumeLabel";
            this.micVolumeLabel.Size = new System.Drawing.Size(106, 27);
            this.micVolumeLabel.TabIndex = 24;
            this.micVolumeLabel.Text = "音量：";
            this.micVolumeLabel.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // micVolumeTrackBar
            // 
            this.micVolumeTrackBar.AutoSize = false;
            this.micVolumeTrackBar.Cursor = System.Windows.Forms.Cursors.Hand;
            this.micVolumeTrackBar.Location = new System.Drawing.Point(100, 159);
            this.micVolumeTrackBar.Maximum = 100;
            this.micVolumeTrackBar.Name = "micVolumeTrackBar";
            this.micVolumeTrackBar.Size = new System.Drawing.Size(235, 28);
            this.micVolumeTrackBar.TabIndex = 25;
            this.micVolumeTrackBar.TickFrequency = 0;
            this.micVolumeTrackBar.TickStyle = System.Windows.Forms.TickStyle.None;
            this.micVolumeTrackBar.Scroll += new System.EventHandler(this.OnMicVolumeTrackBarScroll);
            // 
            // micVolumeNumLabel
            // 
            this.micVolumeNumLabel.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.micVolumeNumLabel.Location = new System.Drawing.Point(332, 154);
            this.micVolumeNumLabel.Name = "micVolumeNumLabel";
            this.micVolumeNumLabel.Size = new System.Drawing.Size(72, 28);
            this.micVolumeNumLabel.TabIndex = 26;
            this.micVolumeNumLabel.Text = "0%";
            this.micVolumeNumLabel.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // speakerVolumeNumLabel
            // 
            this.speakerVolumeNumLabel.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.speakerVolumeNumLabel.Location = new System.Drawing.Point(332, 227);
            this.speakerVolumeNumLabel.Name = "speakerVolumeNumLabel";
            this.speakerVolumeNumLabel.Size = new System.Drawing.Size(72, 28);
            this.speakerVolumeNumLabel.TabIndex = 29;
            this.speakerVolumeNumLabel.Text = "0%";
            this.speakerVolumeNumLabel.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // speakerVolumeTrackBar
            // 
            this.speakerVolumeTrackBar.AutoSize = false;
            this.speakerVolumeTrackBar.Cursor = System.Windows.Forms.Cursors.Hand;
            this.speakerVolumeTrackBar.Location = new System.Drawing.Point(100, 232);
            this.speakerVolumeTrackBar.Maximum = 100;
            this.speakerVolumeTrackBar.Name = "speakerVolumeTrackBar";
            this.speakerVolumeTrackBar.Size = new System.Drawing.Size(235, 28);
            this.speakerVolumeTrackBar.TabIndex = 28;
            this.speakerVolumeTrackBar.TickFrequency = 0;
            this.speakerVolumeTrackBar.TickStyle = System.Windows.Forms.TickStyle.None;
            this.speakerVolumeTrackBar.Scroll += new System.EventHandler(this.OnSpeakerVolumeTrackBarScroll);
            // 
            // speakerVolumeLabel
            // 
            this.speakerVolumeLabel.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.speakerVolumeLabel.Location = new System.Drawing.Point(4, 227);
            this.speakerVolumeLabel.Name = "speakerVolumeLabel";
            this.speakerVolumeLabel.Size = new System.Drawing.Size(106, 27);
            this.speakerVolumeLabel.TabIndex = 27;
            this.speakerVolumeLabel.Text = "音量：";
            this.speakerVolumeLabel.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // TRTCDeviceForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.Gainsboro;
            this.ClientSize = new System.Drawing.Size(431, 325);
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
            this.Controls.Add(this.cameraDeviceComboBox);
            this.Controls.Add(this.cameraDeviceLabel);
            this.Controls.Add(this.confirmBtn);
            this.Controls.Add(this.panel1);
            this.DoubleBuffered = true;
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Name = "TRTCDeviceForm";
            this.ShowInTaskbar = false;
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "TRTCDeviceFrom";
            this.Load += new System.EventHandler(this.OnLoad);
            this.panel1.ResumeLayout(false);
            this.panel1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.exitPicBox)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.micVolumeTrackBar)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.speakerVolumeTrackBar)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Button confirmBtn;
        private System.Windows.Forms.ComboBox cameraDeviceComboBox;
        private System.Windows.Forms.Label cameraDeviceLabel;
        private System.Windows.Forms.ComboBox micDeviceComboBox;
        private System.Windows.Forms.Label micDeviceLabel;
        private System.Windows.Forms.ComboBox speakerDeviceComboBox;
        private System.Windows.Forms.Label speakerDeviceLabel;
        private System.Windows.Forms.Label micVolumeLabel;
        private System.Windows.Forms.TrackBar micVolumeTrackBar;
        private System.Windows.Forms.Label micVolumeNumLabel;
        private System.Windows.Forms.Label speakerVolumeNumLabel;
        private System.Windows.Forms.TrackBar speakerVolumeTrackBar;
        private System.Windows.Forms.Label speakerVolumeLabel;
        private System.Windows.Forms.PictureBox exitPicBox;
    }
}