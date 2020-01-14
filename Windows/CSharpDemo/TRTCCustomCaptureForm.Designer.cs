namespace TRTCCSharpDemo
{
    partial class TRTCCustomCaptureForm
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(TRTCCustomCaptureForm));
            this.label1 = new System.Windows.Forms.Label();
            this.panel1 = new System.Windows.Forms.Panel();
            this.exitPicBox = new System.Windows.Forms.PictureBox();
            this.customAudioCheckBox = new System.Windows.Forms.CheckBox();
            this.confirmBtn = new System.Windows.Forms.Button();
            this.customVideoCheckBox = new System.Windows.Forms.CheckBox();
            this.customAudioComboBox = new System.Windows.Forms.ComboBox();
            this.customVideoComboBox = new System.Windows.Forms.ComboBox();
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
            this.label1.Location = new System.Drawing.Point(11, 12);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(90, 21);
            this.label1.TabIndex = 0;
            this.label1.Text = "自定义采集";
            // 
            // panel1
            // 
            this.panel1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(38)))), ((int)(((byte)(38)))), ((int)(((byte)(38)))));
            this.panel1.Controls.Add(this.exitPicBox);
            this.panel1.Controls.Add(this.label1);
            this.panel1.Location = new System.Drawing.Point(0, 0);
            this.panel1.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(374, 45);
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
            this.exitPicBox.Location = new System.Drawing.Point(341, 10);
            this.exitPicBox.Name = "exitPicBox";
            this.exitPicBox.Size = new System.Drawing.Size(25, 25);
            this.exitPicBox.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.exitPicBox.TabIndex = 27;
            this.exitPicBox.TabStop = false;
            this.exitPicBox.Click += new System.EventHandler(this.OnExitPicBoxClick);
            // 
            // customAudioCheckBox
            // 
            this.customAudioCheckBox.AutoSize = true;
            this.customAudioCheckBox.CheckAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.customAudioCheckBox.Cursor = System.Windows.Forms.Cursors.Hand;
            this.customAudioCheckBox.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.customAudioCheckBox.ForeColor = System.Drawing.SystemColors.ControlText;
            this.customAudioCheckBox.Location = new System.Drawing.Point(15, 79);
            this.customAudioCheckBox.Name = "customAudioCheckBox";
            this.customAudioCheckBox.Size = new System.Drawing.Size(141, 25);
            this.customAudioCheckBox.TabIndex = 9;
            this.customAudioCheckBox.Text = "自定义采集音频";
            this.customAudioCheckBox.UseVisualStyleBackColor = true;
            this.customAudioCheckBox.Click += new System.EventHandler(this.OnCustomAudioCheckBoxClick);
            // 
            // confirmBtn
            // 
            this.confirmBtn.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.confirmBtn.Location = new System.Drawing.Point(140, 192);
            this.confirmBtn.Name = "confirmBtn";
            this.confirmBtn.Size = new System.Drawing.Size(95, 35);
            this.confirmBtn.TabIndex = 33;
            this.confirmBtn.Text = "确定";
            this.confirmBtn.UseVisualStyleBackColor = true;
            this.confirmBtn.Click += new System.EventHandler(this.OnConfirmBtnClick);
            // 
            // customVideoCheckBox
            // 
            this.customVideoCheckBox.AutoSize = true;
            this.customVideoCheckBox.CheckAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.customVideoCheckBox.Cursor = System.Windows.Forms.Cursors.Hand;
            this.customVideoCheckBox.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.customVideoCheckBox.ForeColor = System.Drawing.SystemColors.ControlText;
            this.customVideoCheckBox.Location = new System.Drawing.Point(15, 135);
            this.customVideoCheckBox.Name = "customVideoCheckBox";
            this.customVideoCheckBox.Size = new System.Drawing.Size(141, 25);
            this.customVideoCheckBox.TabIndex = 35;
            this.customVideoCheckBox.Text = "自定义采集视频";
            this.customVideoCheckBox.UseVisualStyleBackColor = true;
            this.customVideoCheckBox.Click += new System.EventHandler(this.OnCustomVideoCheckBoxClick);
            // 
            // customAudioComboBox
            // 
            this.customAudioComboBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.customAudioComboBox.Font = new System.Drawing.Font("微软雅黑", 10F);
            this.customAudioComboBox.FormattingEnabled = true;
            this.customAudioComboBox.Location = new System.Drawing.Point(171, 78);
            this.customAudioComboBox.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.customAudioComboBox.Name = "customAudioComboBox";
            this.customAudioComboBox.Size = new System.Drawing.Size(164, 27);
            this.customAudioComboBox.TabIndex = 36;
            // 
            // customVideoComboBox
            // 
            this.customVideoComboBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.customVideoComboBox.Font = new System.Drawing.Font("微软雅黑", 10F);
            this.customVideoComboBox.FormattingEnabled = true;
            this.customVideoComboBox.Location = new System.Drawing.Point(171, 135);
            this.customVideoComboBox.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.customVideoComboBox.Name = "customVideoComboBox";
            this.customVideoComboBox.Size = new System.Drawing.Size(164, 27);
            this.customVideoComboBox.TabIndex = 37;
            // 
            // TRTCCustomCaptureForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 17F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.Gainsboro;
            this.ClientSize = new System.Drawing.Size(374, 242);
            this.Controls.Add(this.customVideoComboBox);
            this.Controls.Add(this.customAudioComboBox);
            this.Controls.Add(this.customVideoCheckBox);
            this.Controls.Add(this.confirmBtn);
            this.Controls.Add(this.customAudioCheckBox);
            this.Controls.Add(this.panel1);
            this.DoubleBuffered = true;
            this.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.Name = "TRTCCustomCaptureForm";
            this.ShowInTaskbar = false;
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "TRTCCustomDataForm";
            this.Load += new System.EventHandler(this.OnLoad);
            this.panel1.ResumeLayout(false);
            this.panel1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.exitPicBox)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.CheckBox customAudioCheckBox;
        private System.Windows.Forms.Button confirmBtn;
        private System.Windows.Forms.CheckBox customVideoCheckBox;
        private System.Windows.Forms.ComboBox customAudioComboBox;
        private System.Windows.Forms.ComboBox customVideoComboBox;
        private System.Windows.Forms.PictureBox exitPicBox;
    }
}