namespace TRTCCSharpDemo
{
    partial class TRTCBeautyForm
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(TRTCBeautyForm));
            this.label1 = new System.Windows.Forms.Label();
            this.panel1 = new System.Windows.Forms.Panel();
            this.exitPicBox = new System.Windows.Forms.PictureBox();
            this.confirmBtn = new System.Windows.Forms.Button();
            this.beautyTrackBar = new System.Windows.Forms.TrackBar();
            this.beautyLabel = new System.Windows.Forms.Label();
            this.whiteTrackBar = new System.Windows.Forms.TrackBar();
            this.whiteLabel = new System.Windows.Forms.Label();
            this.smoothRadioButton = new System.Windows.Forms.RadioButton();
            this.natureRadioButton = new System.Windows.Forms.RadioButton();
            this.beautyCheckBox = new System.Windows.Forms.CheckBox();
            this.panel1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.exitPicBox)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.beautyTrackBar)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.whiteTrackBar)).BeginInit();
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
            this.label1.Text = "美颜设置";
            // 
            // panel1
            // 
            this.panel1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(38)))), ((int)(((byte)(38)))), ((int)(((byte)(38)))));
            this.panel1.Controls.Add(this.exitPicBox);
            this.panel1.Controls.Add(this.label1);
            this.panel1.Location = new System.Drawing.Point(0, 0);
            this.panel1.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(347, 39);
            this.panel1.TabIndex = 3;
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
            this.exitPicBox.Size = new System.Drawing.Size(23, 23);
            this.exitPicBox.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.exitPicBox.TabIndex = 25;
            this.exitPicBox.TabStop = false;
            this.exitPicBox.Click += new System.EventHandler(this.OnExitPicBoxClick);
            // 
            // confirmBtn
            // 
            this.confirmBtn.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.confirmBtn.Location = new System.Drawing.Point(125, 192);
            this.confirmBtn.Name = "confirmBtn";
            this.confirmBtn.Size = new System.Drawing.Size(94, 33);
            this.confirmBtn.TabIndex = 17;
            this.confirmBtn.Text = "确定";
            this.confirmBtn.UseVisualStyleBackColor = true;
            this.confirmBtn.Click += new System.EventHandler(this.OnConfirmBtnClick);
            // 
            // beautyTrackBar
            // 
            this.beautyTrackBar.AutoSize = false;
            this.beautyTrackBar.LargeChange = 1;
            this.beautyTrackBar.Location = new System.Drawing.Point(116, 106);
            this.beautyTrackBar.Maximum = 9;
            this.beautyTrackBar.Name = "beautyTrackBar";
            this.beautyTrackBar.Size = new System.Drawing.Size(171, 25);
            this.beautyTrackBar.TabIndex = 19;
            this.beautyTrackBar.TickFrequency = 0;
            this.beautyTrackBar.TickStyle = System.Windows.Forms.TickStyle.None;
            this.beautyTrackBar.Scroll += new System.EventHandler(this.OnBeautyTrackBarScroll);
            // 
            // beautyLabel
            // 
            this.beautyLabel.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.beautyLabel.Location = new System.Drawing.Point(49, 100);
            this.beautyLabel.Name = "beautyLabel";
            this.beautyLabel.Size = new System.Drawing.Size(77, 26);
            this.beautyLabel.TabIndex = 18;
            this.beautyLabel.Text = "磨皮：";
            this.beautyLabel.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // whiteTrackBar
            // 
            this.whiteTrackBar.AutoSize = false;
            this.whiteTrackBar.LargeChange = 1;
            this.whiteTrackBar.Location = new System.Drawing.Point(116, 149);
            this.whiteTrackBar.Maximum = 9;
            this.whiteTrackBar.Name = "whiteTrackBar";
            this.whiteTrackBar.Size = new System.Drawing.Size(171, 25);
            this.whiteTrackBar.TabIndex = 21;
            this.whiteTrackBar.TickFrequency = 0;
            this.whiteTrackBar.TickStyle = System.Windows.Forms.TickStyle.None;
            this.whiteTrackBar.Scroll += new System.EventHandler(this.OnWhiteTrackBarScroll);
            // 
            // whiteLabel
            // 
            this.whiteLabel.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.whiteLabel.Location = new System.Drawing.Point(49, 148);
            this.whiteLabel.Name = "whiteLabel";
            this.whiteLabel.Size = new System.Drawing.Size(77, 26);
            this.whiteLabel.TabIndex = 20;
            this.whiteLabel.Text = "美白：";
            this.whiteLabel.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // smoothRadioButton
            // 
            this.smoothRadioButton.AutoSize = true;
            this.smoothRadioButton.Cursor = System.Windows.Forms.Cursors.Hand;
            this.smoothRadioButton.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.smoothRadioButton.Location = new System.Drawing.Point(165, 63);
            this.smoothRadioButton.Name = "smoothRadioButton";
            this.smoothRadioButton.Size = new System.Drawing.Size(60, 25);
            this.smoothRadioButton.TabIndex = 22;
            this.smoothRadioButton.TabStop = true;
            this.smoothRadioButton.Text = "光滑";
            this.smoothRadioButton.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.smoothRadioButton.UseVisualStyleBackColor = true;
            this.smoothRadioButton.CheckedChanged += new System.EventHandler(this.OnSmoothRadioButtonCheckedChanged);
            // 
            // natureRadioButton
            // 
            this.natureRadioButton.AutoSize = true;
            this.natureRadioButton.Cursor = System.Windows.Forms.Cursors.Hand;
            this.natureRadioButton.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.natureRadioButton.Location = new System.Drawing.Point(247, 63);
            this.natureRadioButton.Name = "natureRadioButton";
            this.natureRadioButton.Size = new System.Drawing.Size(60, 25);
            this.natureRadioButton.TabIndex = 23;
            this.natureRadioButton.TabStop = true;
            this.natureRadioButton.Text = "自然";
            this.natureRadioButton.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.natureRadioButton.UseVisualStyleBackColor = true;
            this.natureRadioButton.CheckedChanged += new System.EventHandler(this.OnNatureRadioButtonCheckedChanged);
            // 
            // beautyCheckBox
            // 
            this.beautyCheckBox.AutoSize = true;
            this.beautyCheckBox.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.beautyCheckBox.ForeColor = System.Drawing.SystemColors.ControlText;
            this.beautyCheckBox.Location = new System.Drawing.Point(38, 63);
            this.beautyCheckBox.Name = "beautyCheckBox";
            this.beautyCheckBox.Size = new System.Drawing.Size(93, 25);
            this.beautyCheckBox.TabIndex = 24;
            this.beautyCheckBox.Text = "开启美颜";
            this.beautyCheckBox.UseVisualStyleBackColor = true;
            this.beautyCheckBox.Click += new System.EventHandler(this.OnBeautyCheckBoxClick);
            // 
            // TRTCBeautyForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(96F, 96F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Dpi;
            this.BackColor = System.Drawing.Color.Gainsboro;
            this.ClientSize = new System.Drawing.Size(347, 245);
            this.Controls.Add(this.beautyCheckBox);
            this.Controls.Add(this.natureRadioButton);
            this.Controls.Add(this.smoothRadioButton);
            this.Controls.Add(this.whiteTrackBar);
            this.Controls.Add(this.whiteLabel);
            this.Controls.Add(this.beautyTrackBar);
            this.Controls.Add(this.beautyLabel);
            this.Controls.Add(this.confirmBtn);
            this.Controls.Add(this.panel1);
            this.DoubleBuffered = true;
            this.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.Name = "TRTCBeautyForm";
            this.ShowInTaskbar = false;
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "TRTCBeautyForm";
            this.panel1.ResumeLayout(false);
            this.panel1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.exitPicBox)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.beautyTrackBar)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.whiteTrackBar)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.Button confirmBtn;
        private System.Windows.Forms.TrackBar beautyTrackBar;
        private System.Windows.Forms.Label beautyLabel;
        private System.Windows.Forms.TrackBar whiteTrackBar;
        private System.Windows.Forms.Label whiteLabel;
        private System.Windows.Forms.RadioButton smoothRadioButton;
        private System.Windows.Forms.RadioButton natureRadioButton;
        private System.Windows.Forms.CheckBox beautyCheckBox;
        private System.Windows.Forms.PictureBox exitPicBox;
    }
}