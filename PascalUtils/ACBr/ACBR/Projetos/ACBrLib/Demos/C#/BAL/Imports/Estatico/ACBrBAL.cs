﻿using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;

namespace ACBrLibETQ
{
    public static class ACBrBAL
    {
        #region DLL

        private const string ACBr = "ACBrBAL32.dll";
        //private const string ACBr = "ACBrBAL64.dll";

        #endregion DLL

        #region Imports

        [DllImport(ACBr, CallingConvention = CallingConvention.Cdecl)]
        public static extern int BAL_Inicializar(string eArqConfig, string eChaveCrypt);

        [DllImport(ACBr, CallingConvention = CallingConvention.Cdecl)]
        public static extern int BAL_Finalizar();

        [DllImport(ACBr, CallingConvention = CallingConvention.Cdecl)]
        public static extern int BAL_Nome(StringBuilder buffer, ref int bufferSize);

        [DllImport(ACBr, CallingConvention = CallingConvention.Cdecl)]
        public static extern int BAL_Versao(StringBuilder buffer, ref int bufferSize);

        [DllImport(ACBr, CallingConvention = CallingConvention.Cdecl)]
        public static extern int BAL_UltimoRetorno(StringBuilder buffer, ref int bufferSize);

        [DllImport(ACBr, CallingConvention = CallingConvention.Cdecl)]
        public static extern int BAL_ConfigLer(string eArqConfig);

        [DllImport(ACBr, CallingConvention = CallingConvention.Cdecl)]
        public static extern int BAL_ConfigGravar(string eArqConfig);

        [DllImport(ACBr, CallingConvention = CallingConvention.Cdecl)]
        public static extern int BAL_ConfigLerValor(string eSessao, string eChave, StringBuilder buffer, ref int bufferSize);

        [DllImport(ACBr, CallingConvention = CallingConvention.Cdecl)]
        public static extern int BAL_ConfigGravarValor(string eSessao, string eChave, string valor);

        [DllImport(ACBr, CallingConvention = CallingConvention.Cdecl)]
        public static extern int BAL_Ativar();

        [DllImport(ACBr, CallingConvention = CallingConvention.Cdecl)]
        public static extern int BAL_Desativar();

        #endregion Imports

        #region Methods

        public static string ToUTF8(this string value)
        {
            return string.IsNullOrEmpty(value) ? value : Encoding.Default.GetString(Encoding.UTF8.GetBytes(value));
        }

        public static string FromUTF8(this StringBuilder value)
        {
            if (value == null) return null;
            return value.Length == 0 ? string.Empty : Encoding.UTF8.GetString(Encoding.Default.GetBytes(value.ToString()));
        }

        public static void CheckResult(int ret)
        {
            if (ret >= 0) return;

            var bufferLen = 256;
            var buffer = new StringBuilder(bufferLen);

            BAL_UltimoRetorno(buffer, ref bufferLen);
            if (bufferLen > 256)
            {
                buffer.Capacity = bufferLen;
                BAL_UltimoRetorno(buffer, ref bufferLen);
            }

            switch (ret)
            {
                case -10:
                    throw new ApplicationException(FromUTF8(buffer));

                case -6:
                    throw new DirectoryNotFoundException(FromUTF8(buffer));

                case -5:
                    throw new FileNotFoundException(FromUTF8(buffer));

                case -4:
                    throw new ApplicationException(FromUTF8(buffer));

                case -3:
                    throw new ApplicationException(FromUTF8(buffer));

                case -2:
                    throw new ApplicationException(FromUTF8(buffer));

                case -1:
                    throw new ApplicationException(FromUTF8(buffer));
            }
        }

        #endregion Methods
    }
}