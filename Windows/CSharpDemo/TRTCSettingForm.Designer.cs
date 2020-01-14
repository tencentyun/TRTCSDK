namespace TRTCCSharpDemo
{
    partial class TRTCSettingForm
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(TRTCSettingForm));
            this.panel1 = new System.Windows.Forms.Panel();
            this.exitPicBox = new System.Windows.Forms.PictureBox();
            this.label1 = new System.Windows.Forms.Label();
            this.resolutionLabel = new System.Windows.Forms.Label();
            this.resolutionComboBox = new System.Windows.Forms.ComboBox();
            this.fpsComboBox = new System.Windows.Forms.ComboBox();
            this.fpsLabel = new System.Windows.Forms.Label();
            this.qosComboBox = new System.Windows.Forms.ComboBox();
            this.qosLabel = new System.Windows.Forms.Label();
            this.sceneComboBox = new System.Windows.Forms.ComboBox();
            this.sceneLabel = new System.Windows.Forms.Label();
            this.bitrateLabel = new System.Windows.Forms.Label();
            this.bitrateTrackBar = new System.Windows.Forms.TrackBar();
            this.bitrateNumLabel = new System.Windows.Forms.Label();
            this.pushTypeCheckBox = new System.Windows.Forms.CheckBox();
            this.playTypeCheckBox = new System.Windows.Forms.CheckBox();
            this.saveBtn = new System.Windows.Forms.Button();
            this.cancelBtn = new System.Windows.Forms.Button();
            this.controlComboBox = new System.Windows.Forms.ComboBox();
            this.controlLabel = new System.Windows.Forms.Label();
            this.resolutionModeComboBox = new System.Windows.Forms.ComboBox();
            this.resolutionModeLabel = new System.Windows.Forms.Label();
            this.panel1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.exitPicBox)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.bitrateTrackBar)).BeginInit();
            this.SuspendLayout();
            // 
            // panel1
            // 
            this.panel1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(38)))), ((int)(((byte)(38)))), ((int)(((byte)(38)))));
            this.panel1.Controls.Add(this.exitPicBox);
            this.panel1.Controls.Add(this.label1);
            this.panel1.Location = new System.Drawing.Point(-2, 0);
            this.panel1.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(349, 42);
            this.panel1.TabIndex = 0;
            this.panel1.MouseDown += new System.Windows.Forms.MouseEventHandler(this.OnFormMouseDown);
            this.panel1.MouseMove += new System.Windows.Forms.MouseEventHandler(this.OnFormMouseMove);
            this.panel1.MouseUp += new System.Windows.Forms.MouseEventHandler(this.OnFormMouseUp);
            // 
            // exitPicBox
            // 
            this.exitPicBox.BackgroundImage = global::TRTCCSharpDemo.Properties.Resources.close_white;
            this.exitPicBox.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Zoom;
            this.exitPicBox.Cursor = System.Windows.Forms.Cursors.Hand;
            this.exitPicBox.Location = new System.Drawing.Point(317, 7);
            this.exitPicBox.Name = "exitPicBox";
            this.exitPicBox.Size = new System.Drawing.Size(25, 25);
            this.exitPicBox.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.exitPicBox.TabIndex = 32;
            this.exitPicBox.TabStop = false;
            this.exitPicBox.Click += new System.EventHandler(this.OnExitPicBoxClick);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.label1.ForeColor = System.Drawing.Color.White;
            this.label1.Location = new System.Drawing.Point(11, 9);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(42, 21);
            this.label1.TabIndex = 0;
            this.label1.Text = "设置";
            // 
            // resolutionLabel
            // 
            this.resolutionLabel.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.resolutionLabel.Location = new System.Drawing.Point(60, 64);
            this.resolutionLabel.Name = "resolutionLabel";
            this.resolutionLabel.Size = new System.Drawing.Size(74, 26);
            this.resolutionLabel.TabIndex = 1;
            this.resolutionLabel.Text = "分辨率：";
            this.resolutionLabel.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // resolutionComboBox
            // 
            this.resolutionComboBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.resolutionComboBox.Font = new System.Drawing.Font("微软雅黑", 10F);
            this.resolutionComboBox.FormattingEnabled = true;
            this.resolutionComboBox.Location = new System.Drawing.Point(131, 66);
            this.resolutionComboBox.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.resolutionComboBox.Name = "resolutionComboBox";
            this.resolutionComboBox.Size = new System.Drawing.Size(140, 27);
            this.resolutionComboBox.TabIndex = 2;
            this.resolutionComboBox.SelectedIndexChanged += new System.EventHandler(this.OnResolutionSelectedIndexChanged);
            // 
            // fpsComboBox
            // 
            this.fpsComboBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.fpsComboBox.Font = new System.Drawing.Font("微软雅黑", 10F);
            this.fpsComboBox.FormattingEnabled = true;
            this.fpsComboBox.Location = new System.Drawing.Point(131, 111);
            this.fpsComboBox.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.fpsComboBox.Name = "fpsComboBox";
            this.fpsComboBox.Size = new System.Drawing.Size(140, 27);
            this.fpsComboBox.TabIndex = 4;
            this.fpsComboBox.SelectedIndexChanged += new System.EventHandler(this.OnFpsSelectedIndexChanged);
            // 
            // fpsLabel
            // 
            this.fpsLabel.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.fpsLabel.Location = new System.Drawing.Point(60, 109);
            this.fpsLabel.Name = "fpsLabel";
            this.fpsLabel.Size = new System.Drawing.Size(74, 26);
            this.fpsLabel.TabIndex = 3;
            this.fpsLabel.Text = "帧率：";
            this.fpsLabel.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // qosComboBox
            // 
            this.qosComboBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.qosComboBox.Font = new System.Drawing.Font("微软雅黑", 10F);
            this.qosComboBox.FormattingEnabled = true;
            this.qosComboBox.Location = new System.Drawing.Point(131, 157);
            this.qosComboBox.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.qosComboBox.Name = "qosComboBox";
            this.qosComboBox.Size = new System.Drawing.Size(140, 27);
            this.qosComboBox.TabIndex = 6;
            this.qosComboBox.SelectedIndexChanged += new System.EventHandler(this.OnQosSelectedIndexChanged);
            // 
            // qosLabel
            // 
            this.qosLabel.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.qosLabel.Location = new System.Drawing.Point(27, 155);
            this.qosLabel.Name = "qosLabel";
            this.qosLabel.Size = new System.Drawing.Size(107, 26);
            this.qosLabel.TabIndex = 5;
            this.qosLabel.Text = "画质偏好：";
            this.qosLabel.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // sceneComboBox
            // 
            this.sceneComboBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.sceneComboBox.Font = new System.Drawing.Font("微软雅黑", 10F);
            this.sceneComboBox.FormattingEnabled = true;
            this.sceneComboBox.Location = new System.Drawing.Point(131, 203);
            this.sceneComboBox.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.sceneComboBox.Name = "sceneComboBox";
            this.sceneComboBox.Size = new System.Drawing.Size(140, 27);
            this.sceneComboBox.TabIndex = 8;
            this.sceneComboBox.SelectedIndexChanged += new System.EventHandler(this.OnSceneSelectedIndexChanged);
            // 
            // sceneLabel
            // 
            this.sceneLabel.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.sceneLabel.Location = new System.Drawing.Point(27, 201);
            this.sceneLabel.Name = "sceneLabel";
            this.sceneLabel.Size = new System.Drawing.Size(107, 26);
            this.sceneLabel.TabIndex = 7;
            this.sceneLabel.Text = "应用场景：";
            this.sceneLabel.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // bitrateLabel
            // 
            this.bitrateLabel.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.bitrateLabel.Location = new System.Drawing.Point(23, 330);
            this.bitrateLabel.Name = "bitrateLabel";
            this.bitrateLabel.Size = new System.Drawing.Size(77, 26);
            this.bitrateLabel.TabIndex = 9;
            this.bitrateLabel.Text = "码率：";
            this.bitrateLabel.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // bitrateTrackBar
            // 
            this.bitrateTrackBar.AutoSize = false;
            this.bitrateTrackBar.Location = new System.Drawing.Point(95, 336);
            this.bitrateTrackBar.Maximum = 1500;
            this.bitrateTrackBar.Minimum = 200;
            this.bitrateTrackBar.Name = "bitrateTrackBar";
            this.bitrateTrackBar.Size = new System.Drawing.Size(150, 25);
            this.bitrateTrackBar.TabIndex = 10;
            this.bitrateTrackBar.TickFrequency = 0;
            this.bitrateTrackBar.TickStyle = System.Windows.Forms.TickStyle.None;
            this.bitrateTrackBar.Value = 500;
            this.bitrateTrackBar.Scroll += new System.EventHandler(this.OnBitrateTrackBarScroll);
            // 
            // bitrateNumLabel
            // 
            this.bitrateNumLabel.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.bitrateNumLabel.Location = new System.Drawing.Point(242, 333);
            this.bitrateNumLabel.Name = "bitrateNumLabel";
            this.bitrateNumLabel.Size = new System.Drawing.Size(92, 28);
            this.bitrateNumLabel.TabIndex = 11;
            this.bitrateNumLabel.Text = "kbps";
            this.bitrateNumLabel.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // pushTypeCheckBox
            // 
            this.pushTypeCheckBox.AutoSize = true;
            this.pushTypeCheckBox.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.pushTypeCheckBox.Location = new System.Drawing.Point(48, 370);
            this.pushTypeCheckBox.Name = "pushTypeCheckBox";
            this.pushTypeCheckBox.Size = new System.Drawing.Size(125, 25);
            this.pushTypeCheckBox.TabIndex = 12;
            this.pushTypeCheckBox.Text = "开启双路编码";
            this.pushTypeCheckBox.UseVisualStyleBackColor = true;
            this.pushTypeCheckBox.CheckedChanged += new System.EventHandler(this.OnPushTypeCheckedChanged);
            // 
            // playTypeCheckBox
            // 
            this.playTypeCheckBox.AutoSize = true;
            this.playTypeCheckBox.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.playTypeCheckBox.Location = new System.Drawing.Point(179, 370);
            this.playTypeCheckBox.Name = "playTypeCheckBox";
            this.playTypeCheckBox.Size = new System.Drawing.Size(125, 25);
            this.playTypeCheckBox.TabIndex = 13;
            this.playTypeCheckBox.Text = "默认观看低清";
            this.playTypeCheckBox.UseVisualStyleBackColor = true;
            this.playTypeCheckBox.CheckedChanged += new System.EventHandler(this.OnPlayTypeCheckedChanged);
            // 
            // saveBtn
            // 
            this.saveBtn.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.saveBtn.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.saveBtn.Location = new System.Drawing.Point(78, 409);
            this.saveBtn.Name = "saveBtn";
            this.saveBtn.Size = new System.Drawing.Size(79, 33);
            this.saveBtn.TabIndex = 14;
            this.saveBtn.Text = "保存";
            this.saveBtn.UseVisualStyleBackColor = true;
            this.saveBtn.Click += new System.EventHandler(this.OnSaveBtnClick);
            // 
            // cancelBtn
            // 
            this.cancelBtn.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.cancelBtn.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.cancelBtn.Location = new System.Drawing.Point(179, 409);
            this.cancelBtn.Name = "cancelBtn";
            this.cancelBtn.Size = new System.Drawing.Size(79, 33);
            this.cancelBtn.TabIndex = 15;
            this.cancelBtn.Text = "取消";
            this.cancelBtn.UseVisualStyleBackColor = true;
            this.cancelBtn.Click += new System.EventHandler(this.OnCancelBtnClick);
            // 
            // controlComboBox
            // 
            this.controlComboBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.controlComboBox.Font = new System.Drawing.Font("微软雅黑", 10F);
            this.controlComboBox.FormattingEnabled = true;
            this.controlComboBox.Location = new System.Drawing.Point(131, 249);
            this.controlComboBox.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.controlComboBox.Name = "controlComboBox";
            this.controlComboBox.Size = new System.Drawing.Size(140, 27);
            this.controlComboBox.TabIndex = 17;
            this.controlComboBox.SelectedIndexChanged += new System.EventHandler(this.OnControlComboBoxSelectedIndexChanged);
            // 
            // controlLabel
            // 
            this.controlLabel.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.controlLabel.Location = new System.Drawing.Point(27, 247);
            this.controlLabel.Name = "controlLabel";
            this.controlLabel.Size = new System.Drawing.Size(107, 26);
            this.controlLabel.TabIndex = 16;
            this.controlLabel.Text = "流控方案：";
            this.controlLabel.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // resolutionModeComboBox
            // 
            this.resolutionModeComboBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.resolutionModeComboBox.Font = new System.Drawing.Font("微软雅黑", 10F);
            this.resolutionModeComboBox.FormattingEnabled = true;
            this.resolutionModeComboBox.Location = new System.Drawing.Point(131, 294);
            this.resolutionModeComboBox.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.resolutionModeComboBox.Name = "resolutionModeComboBox";
            this.resolutionModeComboBox.Size = new System.Drawing.Size(140, 27);
            this.resolutionModeComboBox.TabIndex = 19;
            this.resolutionModeComboBox.SelectedIndexChanged += new System.EventHandler(this.OnResolutionModeComboBoxSelectedIndexChanged);
            // 
            // resolutionModeLabel
            // 
            this.resolutionModeLabel.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.resolutionModeLabel.Location = new System.Drawing.Point(27, 292);
            this.resolutionModeLabel.Name = "resolutionModeLabel";
            this.resolutionModeLabel.Size = new System.Drawing.Size(107, 26);
            this.resolutionModeLabel.TabIndex = 18;
            this.resolutionModeLabel.Text = "画面方向：";
            this.resolutionModeLabel.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // TRTCSettingForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 17F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.Gainsboro;
            this.ClientSize = new System.Drawing.Size(346, 461);
            this.Controls.Add(this.resolutionModeComboBox);
            this.Controls.Add(this.resolutionModeLabel);
            this.Controls.Add(this.controlComboBox);
            this.Controls.Add(this.controlLabel);
            this.Controls.Add(this.cancelBtn);
            this.Controls.Add(this.saveBtn);
            this.Controls.Add(this.playTypeCheckBox);
            this.Controls.Add(this.pushTypeCheckBox);
            this.Controls.Add(this.bitrateNumLabel);
            this.Controls.Add(this.bitrateTrackBar);
            this.Controls.Add(this.bitrateLabel);
            this.Controls.Add(this.sceneComboBox);
            this.Controls.Add(this.sceneLabel);
            this.Controls.Add(this.qosComboBox);
            this.Controls.Add(this.qosLabel);
            this.Controls.Add(this.fpsComboBox);
            this.Controls.Add(this.fpsLabel);
            this.Controls.Add(this.resolutionComboBox);
            this.Controls.Add(this.resolutionLabel);
            this.Controls.Add(this.panel1);
            this.DoubleBuffered = true;
            this.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.Name = "TRTCSettingForm";
            this.ShowInTaskbar = false;
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "TRTCSettingFrom";
            this.Load += new System.EventHandler(this.OnLoad);
            this.panel1.ResumeLayout(false);
            this.panel1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.exitPicBox)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.bitrateTrackBar)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label resolutionLabel;
        private System.Windows.Forms.ComboBox resolutionComboBox;
        private System.Windows.Forms.ComboBox fpsComboBox;
        private System.Windows.Forms.Label fpsLabel;
        private System.Windows.Forms.ComboBox qosComboBox;
        private System.Windows.Forms.Label qosLabel;
        private System.Windows.Forms.ComboBox sceneComboBox;
        private System.Windows.Forms.Label sceneLabel;
        private System.Windows.Forms.Label bitrateLabel;
        private System.Windows.Forms.TrackBar bitrateTrackBar;
        private System.Windows.Forms.Label bitrateNumLabel;
        private System.Windows.Forms.CheckBox pushTypeCheckBox;
        private System.Windows.Forms.CheckBox playTypeCheckBox;
        private System.Windows.Forms.Button saveBtn;
        private System.Windows.Forms.Button cancelBtn;
        private System.Windows.Forms.ComboBox controlComboBox;
        private System.Windows.Forms.Label controlLabel;
        private System.Windows.Forms.PictureBox exitPicBox;
        private System.Windows.Forms.ComboBox resolutionModeComboBox;
        private System.Windows.Forms.Label resolutionModeLabel;
    }
}