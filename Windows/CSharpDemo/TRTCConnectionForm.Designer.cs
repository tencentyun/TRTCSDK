namespace TRTCCSharpDemo
{
    partial class TRTCConnectionForm
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(TRTCConnectionForm));
            this.label1 = new System.Windows.Forms.Label();
            this.panel1 = new System.Windows.Forms.Panel();
            this.exitPicBox = new System.Windows.Forms.PictureBox();
            this.disconnectBtn = new System.Windows.Forms.Button();
            this.connectBtn = new System.Windows.Forms.Button();
            this.roomLabel = new System.Windows.Forms.Label();
            this.userLabel = new System.Windows.Forms.Label();
            this.roomTextBox = new System.Windows.Forms.TextBox();
            this.roomPanel = new System.Windows.Forms.Panel();
            this.userTextBox = new System.Windows.Forms.TextBox();
            this.userPanel = new System.Windows.Forms.Panel();
            this.infoLabel = new System.Windows.Forms.Label();
            this.panel1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.exitPicBox)).BeginInit();
            this.roomPanel.SuspendLayout();
            this.userPanel.SuspendLayout();
            this.SuspendLayout();
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Cursor = System.Windows.Forms.Cursors.Default;
            this.label1.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.label1.ForeColor = System.Drawing.Color.White;
            this.label1.Location = new System.Drawing.Point(11, 11);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(74, 21);
            this.label1.TabIndex = 0;
            this.label1.Text = "跨房通话";
            // 
            // panel1
            // 
            this.panel1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(38)))), ((int)(((byte)(38)))), ((int)(((byte)(38)))));
            this.panel1.Controls.Add(this.exitPicBox);
            this.panel1.Controls.Add(this.label1);
            this.panel1.Location = new System.Drawing.Point(0, 0);
            this.panel1.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(389, 43);
            this.panel1.TabIndex = 5;
            this.panel1.MouseDown += new System.Windows.Forms.MouseEventHandler(this.OnFormMouseDown);
            this.panel1.MouseMove += new System.Windows.Forms.MouseEventHandler(this.OnFormMouseMove);
            this.panel1.MouseUp += new System.Windows.Forms.MouseEventHandler(this.OnFormMouseUp);
            // 
            // exitPicBox
            // 
            this.exitPicBox.BackgroundImage = global::TRTCCSharpDemo.Properties.Resources.close_white;
            this.exitPicBox.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Zoom;
            this.exitPicBox.Cursor = System.Windows.Forms.Cursors.Hand;
            this.exitPicBox.Location = new System.Drawing.Point(357, 9);
            this.exitPicBox.Name = "exitPicBox";
            this.exitPicBox.Size = new System.Drawing.Size(25, 25);
            this.exitPicBox.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.exitPicBox.TabIndex = 26;
            this.exitPicBox.TabStop = false;
            this.exitPicBox.Click += new System.EventHandler(this.OnExitPicBoxClick);
            // 
            // disconnectBtn
            // 
            this.disconnectBtn.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.disconnectBtn.Enabled = false;
            this.disconnectBtn.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.disconnectBtn.Location = new System.Drawing.Point(204, 198);
            this.disconnectBtn.Name = "disconnectBtn";
            this.disconnectBtn.Size = new System.Drawing.Size(109, 33);
            this.disconnectBtn.TabIndex = 17;
            this.disconnectBtn.TabStop = false;
            this.disconnectBtn.Text = "结束连麦";
            this.disconnectBtn.UseVisualStyleBackColor = true;
            this.disconnectBtn.Click += new System.EventHandler(this.OnDisconnectBtnClick);
            // 
            // connectBtn
            // 
            this.connectBtn.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.connectBtn.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.connectBtn.Location = new System.Drawing.Point(76, 198);
            this.connectBtn.Name = "connectBtn";
            this.connectBtn.Size = new System.Drawing.Size(109, 33);
            this.connectBtn.TabIndex = 16;
            this.connectBtn.TabStop = false;
            this.connectBtn.Text = "跨房通话";
            this.connectBtn.UseVisualStyleBackColor = true;
            this.connectBtn.Click += new System.EventHandler(this.OnConnectBtnClick);
            // 
            // roomLabel
            // 
            this.roomLabel.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.roomLabel.Location = new System.Drawing.Point(9, 69);
            this.roomLabel.Name = "roomLabel";
            this.roomLabel.Size = new System.Drawing.Size(96, 31);
            this.roomLabel.TabIndex = 20;
            this.roomLabel.Text = "目标房间：";
            this.roomLabel.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // userLabel
            // 
            this.userLabel.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.userLabel.Location = new System.Drawing.Point(9, 129);
            this.userLabel.Name = "userLabel";
            this.userLabel.Size = new System.Drawing.Size(96, 31);
            this.userLabel.TabIndex = 21;
            this.userLabel.Text = "目标用户：";
            this.userLabel.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // roomTextBox
            // 
            this.roomTextBox.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.roomTextBox.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.roomTextBox.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.roomTextBox.Location = new System.Drawing.Point(7, 8);
            this.roomTextBox.Margin = new System.Windows.Forms.Padding(0, 16, 3, 3);
            this.roomTextBox.MaxLength = 10;
            this.roomTextBox.Name = "roomTextBox";
            this.roomTextBox.Size = new System.Drawing.Size(242, 20);
            this.roomTextBox.TabIndex = 5;
            this.roomTextBox.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.OnRoomTextBoxKeyPress);
            // 
            // roomPanel
            // 
            this.roomPanel.BackColor = System.Drawing.Color.White;
            this.roomPanel.Controls.Add(this.roomTextBox);
            this.roomPanel.Location = new System.Drawing.Point(107, 68);
            this.roomPanel.Name = "roomPanel";
            this.roomPanel.Size = new System.Drawing.Size(258, 36);
            this.roomPanel.TabIndex = 22;
            // 
            // userTextBox
            // 
            this.userTextBox.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.userTextBox.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.userTextBox.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.userTextBox.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.userTextBox.Location = new System.Drawing.Point(7, 8);
            this.userTextBox.Margin = new System.Windows.Forms.Padding(0, 16, 3, 3);
            this.userTextBox.Name = "userTextBox";
            this.userTextBox.Size = new System.Drawing.Size(242, 20);
            this.userTextBox.TabIndex = 6;
            // 
            // userPanel
            // 
            this.userPanel.BackColor = System.Drawing.Color.White;
            this.userPanel.Controls.Add(this.userTextBox);
            this.userPanel.Location = new System.Drawing.Point(107, 129);
            this.userPanel.Name = "userPanel";
            this.userPanel.Padding = new System.Windows.Forms.Padding(15, 0, 0, 0);
            this.userPanel.Size = new System.Drawing.Size(258, 36);
            this.userPanel.TabIndex = 23;
            // 
            // infoLabel
            // 
            this.infoLabel.Font = new System.Drawing.Font("微软雅黑", 10F);
            this.infoLabel.ForeColor = System.Drawing.Color.Red;
            this.infoLabel.Location = new System.Drawing.Point(15, 168);
            this.infoLabel.Name = "infoLabel";
            this.infoLabel.Size = new System.Drawing.Size(354, 27);
            this.infoLabel.TabIndex = 24;
            this.infoLabel.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // TRTCConnectionForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(96F, 96F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Dpi;
            this.BackColor = System.Drawing.Color.Gainsboro;
            this.ClientSize = new System.Drawing.Size(389, 243);
            this.Controls.Add(this.infoLabel);
            this.Controls.Add(this.roomLabel);
            this.Controls.Add(this.userLabel);
            this.Controls.Add(this.roomPanel);
            this.Controls.Add(this.userPanel);
            this.Controls.Add(this.disconnectBtn);
            this.Controls.Add(this.connectBtn);
            this.Controls.Add(this.panel1);
            this.DoubleBuffered = true;
            this.Font = new System.Drawing.Font("微软雅黑", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(134)));
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.Name = "TRTCConnectionForm";
            this.ShowInTaskbar = false;
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "TRTCConnectionForm";
            this.panel1.ResumeLayout(false);
            this.panel1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.exitPicBox)).EndInit();
            this.roomPanel.ResumeLayout(false);
            this.roomPanel.PerformLayout();
            this.userPanel.ResumeLayout(false);
            this.userPanel.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.PictureBox exitPicBox;
        private System.Windows.Forms.Button disconnectBtn;
        private System.Windows.Forms.Button connectBtn;
        private System.Windows.Forms.Label roomLabel;
        private System.Windows.Forms.Label userLabel;
        private System.Windows.Forms.TextBox roomTextBox;
        private System.Windows.Forms.Panel roomPanel;
        private System.Windows.Forms.TextBox userTextBox;
        private System.Windows.Forms.Panel userPanel;
        private System.Windows.Forms.Label infoLabel;
    }
}