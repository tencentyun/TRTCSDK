namespace TRTCCSharpDemo
{
    partial class VedioSettingForm
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
            this.cameraDeviceComboBox = new System.Windows.Forms.ComboBox();
            this.cameraDeviceLabel = new System.Windows.Forms.Label();
            this.fpsComboBox = new System.Windows.Forms.ComboBox();
            this.fpsLabel = new System.Windows.Forms.Label();
            this.resolutionComboBox = new System.Windows.Forms.ComboBox();
            this.resolutionLabel = new System.Windows.Forms.Label();
            this.bitrateNumLabel = new System.Windows.Forms.Label();
            this.bitrateTrackBar = new System.Windows.Forms.TrackBar();
            this.bitrateLabel = new System.Windows.Forms.Label();
            this.cancelBtn = new System.Windows.Forms.Button();
            this.saveBtn = new System.Windows.Forms.Button();
            this.panel1 = new System.Windows.Forms.Panel();
            this.exitPicBox = new System.Windows.Forms.PictureBox();
            this.label1 = new System.Windows.Forms.Label();
            this.confirmBtn = new System.Windows.Forms.Button();
            this.resolutionModeComboBox = new System.Windows.Forms.ComboBox();
            this.resolutionModeLabel = new System.Windows.Forms.Label();
            ((System.ComponentModel.ISupportInitialize)(this.bitrateTrackBar)).BeginInit();
            this.panel1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.exitPicBox)).BeginInit();
            this.SuspendLayout();
            // 
            // cameraDeviceComboBox
            // 
            this.cameraDeviceComboBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cameraDeviceComboBox.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.cameraDeviceComboBox.FormattingEnabled = true;
            this.cameraDeviceComboBox.Location = new System.Drawing.Point(121, 61);
            this.cameraDeviceComboBox.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.cameraDeviceComboBox.Name = "cameraDeviceComboBox";
            this.cameraDeviceComboBox.Size = new System.Drawing.Size(282, 28);
            this.cameraDeviceComboBox.TabIndex = 21;
            this.cameraDeviceComboBox.SelectedIndexChanged += new System.EventHandler(this.cameraDeviceComboBox_SelectedIndexChanged);
            // 
            // cameraDeviceLabel
            // 
            this.cameraDeviceLabel.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.cameraDeviceLabel.Location = new System.Drawing.Point(12, 60);
            this.cameraDeviceLabel.Name = "cameraDeviceLabel";
            this.cameraDeviceLabel.Size = new System.Drawing.Size(96, 27);
            this.cameraDeviceLabel.TabIndex = 20;
            this.cameraDeviceLabel.Text = "摄像头：";
            this.cameraDeviceLabel.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // fpsComboBox
            // 
            this.fpsComboBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.fpsComboBox.Font = new System.Drawing.Font("微软雅黑", 10F);
            this.fpsComboBox.FormattingEnabled = true;
            this.fpsComboBox.Location = new System.Drawing.Point(121, 157);
            this.fpsComboBox.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.fpsComboBox.Name = "fpsComboBox";
            this.fpsComboBox.Size = new System.Drawing.Size(140, 27);
            this.fpsComboBox.TabIndex = 25;
            this.fpsComboBox.SelectedIndexChanged += new System.EventHandler(this.fpsComboBox_SelectedIndexChanged);
            // 
            // fpsLabel
            // 
            this.fpsLabel.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.fpsLabel.Location = new System.Drawing.Point(34, 155);
            this.fpsLabel.Name = "fpsLabel";
            this.fpsLabel.Size = new System.Drawing.Size(74, 26);
            this.fpsLabel.TabIndex = 24;
            this.fpsLabel.Text = "帧率：";
            this.fpsLabel.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // resolutionComboBox
            // 
            this.resolutionComboBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.resolutionComboBox.Font = new System.Drawing.Font("微软雅黑", 10F);
            this.resolutionComboBox.FormattingEnabled = true;
            this.resolutionComboBox.Location = new System.Drawing.Point(121, 112);
            this.resolutionComboBox.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.resolutionComboBox.Name = "resolutionComboBox";
            this.resolutionComboBox.Size = new System.Drawing.Size(140, 27);
            this.resolutionComboBox.TabIndex = 23;
            this.resolutionComboBox.SelectedIndexChanged += new System.EventHandler(this.resolutionComboBox_SelectedIndexChanged);
            // 
            // resolutionLabel
            // 
            this.resolutionLabel.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.resolutionLabel.Location = new System.Drawing.Point(34, 110);
            this.resolutionLabel.Name = "resolutionLabel";
            this.resolutionLabel.Size = new System.Drawing.Size(74, 26);
            this.resolutionLabel.TabIndex = 22;
            this.resolutionLabel.Text = "分辨率：";
            this.resolutionLabel.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // bitrateNumLabel
            // 
            this.bitrateNumLabel.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.bitrateNumLabel.Location = new System.Drawing.Point(268, 244);
            this.bitrateNumLabel.Name = "bitrateNumLabel";
            this.bitrateNumLabel.Size = new System.Drawing.Size(92, 28);
            this.bitrateNumLabel.TabIndex = 28;
            this.bitrateNumLabel.Text = "kbps";
            this.bitrateNumLabel.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // bitrateTrackBar
            // 
            this.bitrateTrackBar.AutoSize = false;
            this.bitrateTrackBar.Location = new System.Drawing.Point(121, 247);
            this.bitrateTrackBar.Maximum = 1500;
            this.bitrateTrackBar.Minimum = 200;
            this.bitrateTrackBar.Name = "bitrateTrackBar";
            this.bitrateTrackBar.Size = new System.Drawing.Size(150, 25);
            this.bitrateTrackBar.TabIndex = 27;
            this.bitrateTrackBar.TickFrequency = 0;
            this.bitrateTrackBar.TickStyle = System.Windows.Forms.TickStyle.None;
            this.bitrateTrackBar.Value = 500;
            this.bitrateTrackBar.Scroll += new System.EventHandler(this.bitrateTrackBar_Scroll);
            // 
            // bitrateLabel
            // 
            this.bitrateLabel.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.bitrateLabel.Location = new System.Drawing.Point(31, 241);
            this.bitrateLabel.Name = "bitrateLabel";
            this.bitrateLabel.Size = new System.Drawing.Size(77, 26);
            this.bitrateLabel.TabIndex = 26;
            this.bitrateLabel.Text = "码率：";
            this.bitrateLabel.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // cancelBtn
            // 
            this.cancelBtn.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.cancelBtn.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.cancelBtn.Location = new System.Drawing.Point(185, 215);
            this.cancelBtn.Name = "cancelBtn";
            this.cancelBtn.Size = new System.Drawing.Size(0, 33);
            this.cancelBtn.TabIndex = 30;
            this.cancelBtn.Text = "取消";
            this.cancelBtn.UseVisualStyleBackColor = true;
            // 
            // saveBtn
            // 
            this.saveBtn.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.saveBtn.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.saveBtn.Location = new System.Drawing.Point(84, 215);
            this.saveBtn.Name = "saveBtn";
            this.saveBtn.Size = new System.Drawing.Size(0, 33);
            this.saveBtn.TabIndex = 29;
            this.saveBtn.Text = "保存";
            this.saveBtn.UseVisualStyleBackColor = true;
            // 
            // panel1
            // 
            this.panel1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(38)))), ((int)(((byte)(38)))), ((int)(((byte)(38)))));
            this.panel1.Controls.Add(this.exitPicBox);
            this.panel1.Controls.Add(this.label1);
            this.panel1.Location = new System.Drawing.Point(1, -5);
            this.panel1.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(422, 42);
            this.panel1.TabIndex = 31;
            this.panel1.MouseDown += new System.Windows.Forms.MouseEventHandler(this.OnFormMouseDown);
            this.panel1.MouseMove += new System.Windows.Forms.MouseEventHandler(this.OnFormMouseMove);
            this.panel1.MouseUp += new System.Windows.Forms.MouseEventHandler(this.OnFormMouseUp);
            // 
            // exitPicBox
            // 
            this.exitPicBox.BackgroundImage = global::TRTCCSharpDemo.Properties.Resources.close_white;
            this.exitPicBox.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Zoom;
            this.exitPicBox.Cursor = System.Windows.Forms.Cursors.Hand;
            this.exitPicBox.Location = new System.Drawing.Point(388, 9);
            this.exitPicBox.Name = "exitPicBox";
            this.exitPicBox.Size = new System.Drawing.Size(25, 25);
            this.exitPicBox.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.exitPicBox.TabIndex = 32;
            this.exitPicBox.TabStop = false;
            this.exitPicBox.Click += new System.EventHandler(this.exitPicBox_Click);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.label1.ForeColor = System.Drawing.Color.White;
            this.label1.Location = new System.Drawing.Point(11, 9);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(74, 21);
            this.label1.TabIndex = 0;
            this.label1.Text = "视频设置";
            // 
            // confirmBtn
            // 
            this.confirmBtn.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.confirmBtn.Location = new System.Drawing.Point(145, 305);
            this.confirmBtn.Name = "confirmBtn";
            this.confirmBtn.Size = new System.Drawing.Size(104, 36);
            this.confirmBtn.TabIndex = 32;
            this.confirmBtn.Text = "确定";
            this.confirmBtn.UseVisualStyleBackColor = true;
            this.confirmBtn.Click += new System.EventHandler(this.confirmBtn_Click);
            // 
            // resolutionModeComboBox
            // 
            this.resolutionModeComboBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.resolutionModeComboBox.Font = new System.Drawing.Font("微软雅黑", 10F);
            this.resolutionModeComboBox.FormattingEnabled = true;
            this.resolutionModeComboBox.Location = new System.Drawing.Point(121, 197);
            this.resolutionModeComboBox.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.resolutionModeComboBox.Name = "resolutionModeComboBox";
            this.resolutionModeComboBox.Size = new System.Drawing.Size(140, 27);
            this.resolutionModeComboBox.TabIndex = 34;
            this.resolutionModeComboBox.SelectedIndexChanged += new System.EventHandler(this.resolutionModeComboBox_SelectedIndexChanged);
            // 
            // resolutionModeLabel
            // 
            this.resolutionModeLabel.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.resolutionModeLabel.Location = new System.Drawing.Point(1, 195);
            this.resolutionModeLabel.Name = "resolutionModeLabel";
            this.resolutionModeLabel.Size = new System.Drawing.Size(107, 26);
            this.resolutionModeLabel.TabIndex = 33;
            this.resolutionModeLabel.Text = "画面方向：";
            this.resolutionModeLabel.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // VedioSettingForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.Gainsboro;
            this.ClientSize = new System.Drawing.Size(426, 368);
            this.Controls.Add(this.resolutionModeComboBox);
            this.Controls.Add(this.resolutionModeLabel);
            this.Controls.Add(this.confirmBtn);
            this.Controls.Add(this.panel1);
            this.Controls.Add(this.cancelBtn);
            this.Controls.Add(this.saveBtn);
            this.Controls.Add(this.bitrateNumLabel);
            this.Controls.Add(this.bitrateTrackBar);
            this.Controls.Add(this.bitrateLabel);
            this.Controls.Add(this.fpsComboBox);
            this.Controls.Add(this.fpsLabel);
            this.Controls.Add(this.resolutionComboBox);
            this.Controls.Add(this.resolutionLabel);
            this.Controls.Add(this.cameraDeviceComboBox);
            this.Controls.Add(this.cameraDeviceLabel);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
            this.Name = "VedioSettingForm";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "VedioSettingForm";
            this.Load += new System.EventHandler(this.OnLoad);
            ((System.ComponentModel.ISupportInitialize)(this.bitrateTrackBar)).EndInit();
            this.panel1.ResumeLayout(false);
            this.panel1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.exitPicBox)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.ComboBox cameraDeviceComboBox;
        private System.Windows.Forms.Label cameraDeviceLabel;
        private System.Windows.Forms.ComboBox fpsComboBox;
        private System.Windows.Forms.Label fpsLabel;
        private System.Windows.Forms.ComboBox resolutionComboBox;
        private System.Windows.Forms.Label resolutionLabel;
        private System.Windows.Forms.Label bitrateNumLabel;
        private System.Windows.Forms.TrackBar bitrateTrackBar;
        private System.Windows.Forms.Label bitrateLabel;
        private System.Windows.Forms.Button cancelBtn;
        private System.Windows.Forms.Button saveBtn;
        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.PictureBox exitPicBox;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Button confirmBtn;
        private System.Windows.Forms.ComboBox resolutionModeComboBox;
        private System.Windows.Forms.Label resolutionModeLabel;
    }
}