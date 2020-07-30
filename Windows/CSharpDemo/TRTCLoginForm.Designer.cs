namespace TRTCCSharpDemo
{
    partial class TRTCLoginForm
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(TRTCLoginForm));
            this.logoPictureBox = new System.Windows.Forms.PictureBox();
            this.userLabel = new System.Windows.Forms.Label();
            this.roomLabel = new System.Windows.Forms.Label();
            this.exitPicBox = new System.Windows.Forms.PictureBox();
            this.userPanel = new System.Windows.Forms.Panel();
            this.userTextBox = new System.Windows.Forms.TextBox();
            this.roomPanel = new System.Windows.Forms.Panel();
            this.roomTextBox = new System.Windows.Forms.TextBox();
            this.formalEnvRadioBtn = new System.Windows.Forms.RadioButton();
            this.joinBtn = new System.Windows.Forms.Button();
            this.tableLayoutPanel1 = new System.Windows.Forms.TableLayoutPanel();
            this.audioRadioBtn = new System.Windows.Forms.RadioButton();
            this.videoRadioBtn = new System.Windows.Forms.RadioButton();
            this.tableLayoutPanel2 = new System.Windows.Forms.TableLayoutPanel();
            this.testEnvRadioBtn = new System.Windows.Forms.RadioButton();
            this.lifeEnvRadioBtn = new System.Windows.Forms.RadioButton();
            ((System.ComponentModel.ISupportInitialize)(this.logoPictureBox)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.exitPicBox)).BeginInit();
            this.userPanel.SuspendLayout();
            this.roomPanel.SuspendLayout();
            this.tableLayoutPanel1.SuspendLayout();
            this.tableLayoutPanel2.SuspendLayout();
            this.SuspendLayout();
            // 
            // logoPictureBox
            // 
            this.logoPictureBox.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.logoPictureBox.BackgroundImage = global::TRTCCSharpDemo.Properties.Resources.logo_court;
            this.logoPictureBox.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Zoom;
            this.logoPictureBox.Location = new System.Drawing.Point(102, 33);
            this.logoPictureBox.Name = "logoPictureBox";
            this.logoPictureBox.Size = new System.Drawing.Size(229, 36);
            this.logoPictureBox.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.logoPictureBox.TabIndex = 0;
            this.logoPictureBox.TabStop = false;
            // 
            // userLabel
            // 
            this.userLabel.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.userLabel.AutoSize = true;
            this.userLabel.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.userLabel.Location = new System.Drawing.Point(43, 165);
            this.userLabel.Name = "userLabel";
            this.userLabel.Size = new System.Drawing.Size(58, 21);
            this.userLabel.TabIndex = 1;
            this.userLabel.Text = "用户：";
            // 
            // roomLabel
            // 
            this.roomLabel.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.roomLabel.AutoSize = true;
            this.roomLabel.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.roomLabel.Location = new System.Drawing.Point(43, 106);
            this.roomLabel.Name = "roomLabel";
            this.roomLabel.Size = new System.Drawing.Size(58, 21);
            this.roomLabel.TabIndex = 2;
            this.roomLabel.Text = "房间：";
            // 
            // exitPicBox
            // 
            this.exitPicBox.BackgroundImage = global::TRTCCSharpDemo.Properties.Resources.close_normal;
            this.exitPicBox.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Zoom;
            this.exitPicBox.Cursor = System.Windows.Forms.Cursors.Hand;
            this.exitPicBox.Location = new System.Drawing.Point(387, 4);
            this.exitPicBox.Name = "exitPicBox";
            this.exitPicBox.Size = new System.Drawing.Size(27, 27);
            this.exitPicBox.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.exitPicBox.TabIndex = 3;
            this.exitPicBox.TabStop = false;
            this.exitPicBox.Click += new System.EventHandler(this.OnExitPicBoxClick);
            // 
            // userPanel
            // 
            this.userPanel.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.userPanel.BackColor = System.Drawing.Color.White;
            this.userPanel.Controls.Add(this.userTextBox);
            this.userPanel.Location = new System.Drawing.Point(107, 156);
            this.userPanel.Name = "userPanel";
            this.userPanel.Padding = new System.Windows.Forms.Padding(15, 0, 0, 0);
            this.userPanel.Size = new System.Drawing.Size(265, 40);
            this.userPanel.TabIndex = 3;
            // 
            // userTextBox
            // 
            this.userTextBox.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.userTextBox.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.userTextBox.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.userTextBox.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.userTextBox.Location = new System.Drawing.Point(11, 10);
            this.userTextBox.Margin = new System.Windows.Forms.Padding(0, 16, 3, 3);
            this.userTextBox.Name = "userTextBox";
            this.userTextBox.Size = new System.Drawing.Size(242, 20);
            this.userTextBox.TabIndex = 5;
            this.userTextBox.Text = "TRTC_TEST_USER01";
            this.userTextBox.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            // 
            // roomPanel
            // 
            this.roomPanel.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.roomPanel.BackColor = System.Drawing.Color.White;
            this.roomPanel.Controls.Add(this.roomTextBox);
            this.roomPanel.Location = new System.Drawing.Point(107, 96);
            this.roomPanel.Name = "roomPanel";
            this.roomPanel.Size = new System.Drawing.Size(265, 40);
            this.roomPanel.TabIndex = 4;
            // 
            // roomTextBox
            // 
            this.roomTextBox.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.roomTextBox.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.roomTextBox.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.roomTextBox.Location = new System.Drawing.Point(10, 10);
            this.roomTextBox.Margin = new System.Windows.Forms.Padding(0, 16, 3, 3);
            this.roomTextBox.MaxLength = 10;
            this.roomTextBox.Name = "roomTextBox";
            this.roomTextBox.Size = new System.Drawing.Size(242, 20);
            this.roomTextBox.TabIndex = 6;
            this.roomTextBox.Text = "901";
            this.roomTextBox.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            this.roomTextBox.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.OnRoomTextBoxKeyPress);
            // 
            // formalEnvRadioBtn
            // 
            this.formalEnvRadioBtn.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Left | System.Windows.Forms.AnchorStyles.Right)));
            this.formalEnvRadioBtn.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.formalEnvRadioBtn.Location = new System.Drawing.Point(3, 3);
            this.formalEnvRadioBtn.Name = "formalEnvRadioBtn";
            this.formalEnvRadioBtn.Size = new System.Drawing.Size(111, 22);
            this.formalEnvRadioBtn.TabIndex = 8;
            this.formalEnvRadioBtn.TabStop = true;
            this.formalEnvRadioBtn.Text = "正式环境";
            this.formalEnvRadioBtn.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.formalEnvRadioBtn.UseVisualStyleBackColor = true;
            this.formalEnvRadioBtn.Visible = false;
            // 
            // joinBtn
            // 
            this.joinBtn.Anchor = System.Windows.Forms.AnchorStyles.Top;
            this.joinBtn.BackColor = System.Drawing.SystemColors.MenuHighlight;
            this.tableLayoutPanel1.SetColumnSpan(this.joinBtn, 6);
            this.joinBtn.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.joinBtn.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.joinBtn.ForeColor = System.Drawing.Color.White;
            this.joinBtn.Location = new System.Drawing.Point(113, 31);
            this.joinBtn.Name = "joinBtn";
            this.joinBtn.Size = new System.Drawing.Size(118, 35);
            this.joinBtn.TabIndex = 7;
            this.joinBtn.Text = "进房";
            this.joinBtn.UseVisualStyleBackColor = false;
            this.joinBtn.Click += new System.EventHandler(this.OnJoinRoomBtnClick);
            // 
            // tableLayoutPanel1
            // 
            this.tableLayoutPanel1.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.tableLayoutPanel1.AutoSize = true;
            this.tableLayoutPanel1.ColumnCount = 6;
            this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 16.66F));
            this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 16.66F));
            this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 16.67F));
            this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 16.67F));
            this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 16.67F));
            this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 16.67F));
            this.tableLayoutPanel1.Controls.Add(this.audioRadioBtn, 0, 1);
            this.tableLayoutPanel1.Controls.Add(this.videoRadioBtn, 3, 1);
            this.tableLayoutPanel1.Controls.Add(this.joinBtn, 0, 2);
            this.tableLayoutPanel1.Location = new System.Drawing.Point(39, 227);
            this.tableLayoutPanel1.Name = "tableLayoutPanel1";
            this.tableLayoutPanel1.RowCount = 3;
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle());
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle());
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle());
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 20F));
            this.tableLayoutPanel1.Size = new System.Drawing.Size(345, 69);
            this.tableLayoutPanel1.TabIndex = 9;
            // 
            // audioRadioBtn
            // 
            this.audioRadioBtn.Anchor = System.Windows.Forms.AnchorStyles.Right;
            this.tableLayoutPanel1.SetColumnSpan(this.audioRadioBtn, 3);
            this.audioRadioBtn.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.audioRadioBtn.Location = new System.Drawing.Point(59, 3);
            this.audioRadioBtn.Name = "audioRadioBtn";
            this.audioRadioBtn.Size = new System.Drawing.Size(109, 22);
            this.audioRadioBtn.TabIndex = 12;
            this.audioRadioBtn.TabStop = true;
            this.audioRadioBtn.Text = "语音通话";
            this.audioRadioBtn.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.audioRadioBtn.UseVisualStyleBackColor = true;
            this.audioRadioBtn.Visible = false;
            // 
            // videoRadioBtn
            // 
            this.videoRadioBtn.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.tableLayoutPanel1.SetColumnSpan(this.videoRadioBtn, 3);
            this.videoRadioBtn.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.videoRadioBtn.Location = new System.Drawing.Point(174, 3);
            this.videoRadioBtn.Name = "videoRadioBtn";
            this.videoRadioBtn.Size = new System.Drawing.Size(109, 22);
            this.videoRadioBtn.TabIndex = 11;
            this.videoRadioBtn.TabStop = true;
            this.videoRadioBtn.Text = "视频通话";
            this.videoRadioBtn.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.videoRadioBtn.UseVisualStyleBackColor = true;
            this.videoRadioBtn.Visible = false;
            // 
            // tableLayoutPanel2
            // 
            this.tableLayoutPanel2.AutoSize = true;
            this.tableLayoutPanel2.ColumnCount = 3;
            this.tableLayoutPanel2.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 33.33333F));
            this.tableLayoutPanel2.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 33.33333F));
            this.tableLayoutPanel2.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 33.33333F));
            this.tableLayoutPanel2.Controls.Add(this.testEnvRadioBtn, 1, 0);
            this.tableLayoutPanel2.Controls.Add(this.lifeEnvRadioBtn, 2, 0);
            this.tableLayoutPanel2.Controls.Add(this.formalEnvRadioBtn, 0, 0);
            this.tableLayoutPanel2.Location = new System.Drawing.Point(39, 199);
            this.tableLayoutPanel2.Name = "tableLayoutPanel2";
            this.tableLayoutPanel2.RowCount = 1;
            this.tableLayoutPanel2.RowStyles.Add(new System.Windows.Forms.RowStyle());
            this.tableLayoutPanel2.Size = new System.Drawing.Size(351, 28);
            this.tableLayoutPanel2.TabIndex = 10;
            // 
            // testEnvRadioBtn
            // 
            this.testEnvRadioBtn.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Left | System.Windows.Forms.AnchorStyles.Right)));
            this.testEnvRadioBtn.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.testEnvRadioBtn.Location = new System.Drawing.Point(120, 3);
            this.testEnvRadioBtn.Name = "testEnvRadioBtn";
            this.testEnvRadioBtn.Size = new System.Drawing.Size(111, 22);
            this.testEnvRadioBtn.TabIndex = 9;
            this.testEnvRadioBtn.TabStop = true;
            this.testEnvRadioBtn.Text = "测试环境";
            this.testEnvRadioBtn.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.testEnvRadioBtn.UseVisualStyleBackColor = true;
            this.testEnvRadioBtn.Visible = false;
            // 
            // lifeEnvRadioBtn
            // 
            this.lifeEnvRadioBtn.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Left | System.Windows.Forms.AnchorStyles.Right)));
            this.lifeEnvRadioBtn.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.lifeEnvRadioBtn.Location = new System.Drawing.Point(237, 3);
            this.lifeEnvRadioBtn.Name = "lifeEnvRadioBtn";
            this.lifeEnvRadioBtn.Size = new System.Drawing.Size(111, 22);
            this.lifeEnvRadioBtn.TabIndex = 10;
            this.lifeEnvRadioBtn.TabStop = true;
            this.lifeEnvRadioBtn.Text = "体验环境";
            this.lifeEnvRadioBtn.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.lifeEnvRadioBtn.UseVisualStyleBackColor = true;
            this.lifeEnvRadioBtn.Visible = false;
            // 
            // TRTCLoginForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(96F, 96F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Dpi;
            this.AutoSize = true;
            this.BackColor = System.Drawing.SystemColors.Control;
            this.ClientSize = new System.Drawing.Size(420, 301);
            this.Controls.Add(this.tableLayoutPanel2);
            this.Controls.Add(this.tableLayoutPanel1);
            this.Controls.Add(this.roomPanel);
            this.Controls.Add(this.userPanel);
            this.Controls.Add(this.exitPicBox);
            this.Controls.Add(this.roomLabel);
            this.Controls.Add(this.userLabel);
            this.Controls.Add(this.logoPictureBox);
            this.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.MaximumSize = new System.Drawing.Size(420, 310);
            this.MinimumSize = new System.Drawing.Size(420, 260);
            this.Name = "TRTCLoginForm";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "TRTCCSharpDemo";
            this.Load += new System.EventHandler(this.OnLoad);
            this.MouseDown += new System.Windows.Forms.MouseEventHandler(this.OnFormMouseDown);
            this.MouseMove += new System.Windows.Forms.MouseEventHandler(this.OnFormMouseMove);
            this.MouseUp += new System.Windows.Forms.MouseEventHandler(this.OnFormMouseUp);
            ((System.ComponentModel.ISupportInitialize)(this.logoPictureBox)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.exitPicBox)).EndInit();
            this.userPanel.ResumeLayout(false);
            this.userPanel.PerformLayout();
            this.roomPanel.ResumeLayout(false);
            this.roomPanel.PerformLayout();
            this.tableLayoutPanel1.ResumeLayout(false);
            this.tableLayoutPanel2.ResumeLayout(false);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.PictureBox logoPictureBox;
        private System.Windows.Forms.Label userLabel;
        private System.Windows.Forms.Label roomLabel;
        private System.Windows.Forms.PictureBox exitPicBox;
        private System.Windows.Forms.Panel userPanel;
        private System.Windows.Forms.Panel roomPanel;
        private System.Windows.Forms.TextBox userTextBox;
        private System.Windows.Forms.TextBox roomTextBox;
        private System.Windows.Forms.RadioButton formalEnvRadioBtn;
        private System.Windows.Forms.Button joinBtn;
        private System.Windows.Forms.TableLayoutPanel tableLayoutPanel1;
        private System.Windows.Forms.RadioButton audioRadioBtn;
        private System.Windows.Forms.RadioButton videoRadioBtn;
        private System.Windows.Forms.TableLayoutPanel tableLayoutPanel2;
        private System.Windows.Forms.RadioButton testEnvRadioBtn;
        private System.Windows.Forms.RadioButton lifeEnvRadioBtn;
    }
}