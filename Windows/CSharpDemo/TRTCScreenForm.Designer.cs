using System;
using System.Windows.Forms;

namespace TRTCCSharpDemo
{
    partial class TRTCScreenForm
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(TRTCScreenForm));
            this.panel1 = new System.Windows.Forms.Panel();
            this.label1 = new System.Windows.Forms.Label();
            this.screenComboBox = new System.Windows.Forms.ComboBox();
            this.screenLabel = new System.Windows.Forms.Label();
            this.LeftTextBox = new System.Windows.Forms.TextBox();
            this.leftLabel = new System.Windows.Forms.Label();
            this.rightLabel = new System.Windows.Forms.Label();
            this.rightTextBox = new System.Windows.Forms.TextBox();
            this.topLabel = new System.Windows.Forms.Label();
            this.topTextBox = new System.Windows.Forms.TextBox();
            this.bottomLabel = new System.Windows.Forms.Label();
            this.bottomTextBox = new System.Windows.Forms.TextBox();
            this.confirmBtn = new System.Windows.Forms.Button();
            this.cancelBtn = new System.Windows.Forms.Button();
            this.panel1.SuspendLayout();
            this.SuspendLayout();
            // 
            // panel1
            // 
            this.panel1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(38)))), ((int)(((byte)(38)))), ((int)(((byte)(38)))));
            this.panel1.Controls.Add(this.label1);
            this.panel1.Location = new System.Drawing.Point(0, 0);
            this.panel1.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(445, 42);
            this.panel1.TabIndex = 2;
            this.panel1.MouseDown += new System.Windows.Forms.MouseEventHandler(this.OnFormMouseDown);
            this.panel1.MouseMove += new System.Windows.Forms.MouseEventHandler(this.OnFormMouseMove);
            this.panel1.MouseUp += new System.Windows.Forms.MouseEventHandler(this.OnFormMouseUp);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Cursor = System.Windows.Forms.Cursors.Default;
            this.label1.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.label1.ForeColor = System.Drawing.Color.White;
            this.label1.Location = new System.Drawing.Point(11, 9);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(100, 21);
            this.label1.TabIndex = 0;
            this.label1.Text = "TRTCScreen";
            // 
            // screenComboBox
            // 
            this.screenComboBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.screenComboBox.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.screenComboBox.FormattingEnabled = true;
            this.screenComboBox.Location = new System.Drawing.Point(116, 79);
            this.screenComboBox.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.screenComboBox.Name = "screenComboBox";
            this.screenComboBox.Size = new System.Drawing.Size(288, 28);
            this.screenComboBox.TabIndex = 21;
            // 
            // screenLabel
            // 
            this.screenLabel.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.screenLabel.Location = new System.Drawing.Point(25, 78);
            this.screenLabel.Name = "screenLabel";
            this.screenLabel.Size = new System.Drawing.Size(96, 27);
            this.screenLabel.TabIndex = 20;
            this.screenLabel.Text = "屏幕列表：";
            this.screenLabel.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // LeftTextBox
            // 
            this.LeftTextBox.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.LeftTextBox.Location = new System.Drawing.Point(106, 129);
            this.LeftTextBox.MaxLength = 4;
            this.LeftTextBox.Name = "LeftTextBox";
            this.LeftTextBox.Size = new System.Drawing.Size(100, 27);
            this.LeftTextBox.TabIndex = 22;
            this.LeftTextBox.Text = "0";
            this.LeftTextBox.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            this.LeftTextBox.WordWrap = false;
            this.LeftTextBox.TextChanged += new System.EventHandler(this.OnLeftTextBoxTextChanged);
            this.LeftTextBox.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.OnLeftTextBoxKeyPress);
            // 
            // leftLabel
            // 
            this.leftLabel.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.leftLabel.Location = new System.Drawing.Point(34, 128);
            this.leftLabel.Name = "leftLabel";
            this.leftLabel.Size = new System.Drawing.Size(66, 27);
            this.leftLabel.TabIndex = 25;
            this.leftLabel.Text = "Left：";
            this.leftLabel.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // rightLabel
            // 
            this.rightLabel.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.rightLabel.Location = new System.Drawing.Point(212, 127);
            this.rightLabel.Name = "rightLabel";
            this.rightLabel.Size = new System.Drawing.Size(86, 27);
            this.rightLabel.TabIndex = 27;
            this.rightLabel.Text = "Right：";
            this.rightLabel.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // rightTextBox
            // 
            this.rightTextBox.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.rightTextBox.Location = new System.Drawing.Point(304, 128);
            this.rightTextBox.MaxLength = 4;
            this.rightTextBox.Name = "rightTextBox";
            this.rightTextBox.Size = new System.Drawing.Size(100, 27);
            this.rightTextBox.TabIndex = 26;
            this.rightTextBox.Text = "0";
            this.rightTextBox.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            this.rightTextBox.WordWrap = false;
            this.rightTextBox.TextChanged += new System.EventHandler(this.OnRightTextBoxTextChanged);
            this.rightTextBox.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.OnRightTextBoxKeyPress);
            // 
            // topLabel
            // 
            this.topLabel.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.topLabel.Location = new System.Drawing.Point(34, 176);
            this.topLabel.Name = "topLabel";
            this.topLabel.Size = new System.Drawing.Size(66, 27);
            this.topLabel.TabIndex = 29;
            this.topLabel.Text = "Top：";
            this.topLabel.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // topTextBox
            // 
            this.topTextBox.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.topTextBox.Location = new System.Drawing.Point(106, 177);
            this.topTextBox.MaxLength = 4;
            this.topTextBox.Name = "topTextBox";
            this.topTextBox.Size = new System.Drawing.Size(100, 27);
            this.topTextBox.TabIndex = 28;
            this.topTextBox.Text = "0";
            this.topTextBox.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            this.topTextBox.WordWrap = false;
            this.topTextBox.TextChanged += new System.EventHandler(this.OnTopTextBoxTextChanged);
            this.topTextBox.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.OnTopTextBoxKeyPress);
            // 
            // bottomLabel
            // 
            this.bottomLabel.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.bottomLabel.Location = new System.Drawing.Point(212, 175);
            this.bottomLabel.Name = "bottomLabel";
            this.bottomLabel.Size = new System.Drawing.Size(86, 27);
            this.bottomLabel.TabIndex = 31;
            this.bottomLabel.Text = "Bottom：";
            this.bottomLabel.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // bottomTextBox
            // 
            this.bottomTextBox.Font = new System.Drawing.Font("微软雅黑", 11F);
            this.bottomTextBox.Location = new System.Drawing.Point(304, 176);
            this.bottomTextBox.MaxLength = 4;
            this.bottomTextBox.Name = "bottomTextBox";
            this.bottomTextBox.Size = new System.Drawing.Size(100, 27);
            this.bottomTextBox.TabIndex = 30;
            this.bottomTextBox.Text = "0";
            this.bottomTextBox.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            this.bottomTextBox.WordWrap = false;
            this.bottomTextBox.TextChanged += new System.EventHandler(this.OnBottomTextBoxTextChanged);
            this.bottomTextBox.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.OnBottomTextBoxKeyPress);
            // 
            // confirmBtn
            // 
            this.confirmBtn.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.confirmBtn.Location = new System.Drawing.Point(119, 229);
            this.confirmBtn.Name = "confirmBtn";
            this.confirmBtn.Size = new System.Drawing.Size(95, 35);
            this.confirmBtn.TabIndex = 23;
            this.confirmBtn.Text = "确定";
            this.confirmBtn.UseVisualStyleBackColor = true;
            this.confirmBtn.Click += new System.EventHandler(this.OnSaveBtnClick);
            // 
            // cancelBtn
            // 
            this.cancelBtn.Font = new System.Drawing.Font("微软雅黑", 12F);
            this.cancelBtn.Location = new System.Drawing.Point(229, 229);
            this.cancelBtn.Name = "cancelBtn";
            this.cancelBtn.Size = new System.Drawing.Size(95, 35);
            this.cancelBtn.TabIndex = 32;
            this.cancelBtn.Text = "取消";
            this.cancelBtn.UseVisualStyleBackColor = true;
            this.cancelBtn.Click += new System.EventHandler(this.OnCancelBtnClick);
            // 
            // TRTCScreenForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.Gainsboro;
            this.ClientSize = new System.Drawing.Size(445, 292);
            this.Controls.Add(this.cancelBtn);
            this.Controls.Add(this.bottomLabel);
            this.Controls.Add(this.bottomTextBox);
            this.Controls.Add(this.topLabel);
            this.Controls.Add(this.topTextBox);
            this.Controls.Add(this.rightLabel);
            this.Controls.Add(this.rightTextBox);
            this.Controls.Add(this.leftLabel);
            this.Controls.Add(this.confirmBtn);
            this.Controls.Add(this.LeftTextBox);
            this.Controls.Add(this.screenComboBox);
            this.Controls.Add(this.screenLabel);
            this.Controls.Add(this.panel1);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Name = "TRTCScreenForm";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "TRTCScreenForm";
            this.Load += new System.EventHandler(this.OnLoad);
            this.panel1.ResumeLayout(false);
            this.panel1.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.ComboBox screenComboBox;
        private System.Windows.Forms.Label screenLabel;
        private System.Windows.Forms.TextBox LeftTextBox;
        private System.Windows.Forms.Label leftLabel;
        private System.Windows.Forms.Label rightLabel;
        private System.Windows.Forms.TextBox rightTextBox;
        private System.Windows.Forms.Label topLabel;
        private System.Windows.Forms.TextBox topTextBox;
        private System.Windows.Forms.Label bottomLabel;
        private System.Windows.Forms.TextBox bottomTextBox;
        private Button confirmBtn;
        private Button cancelBtn;
    }
}