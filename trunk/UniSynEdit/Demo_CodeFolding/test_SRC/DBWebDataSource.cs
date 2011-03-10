/*******************************************************}
{                                                       }
{               Borland DB Web                          }
{           Data aware Web controls                     }
{ Copyright (c) 2003, 2005 Borland Software Corporation }
{                                                       }
{*******************************************************/

using System;
using System.IO;
using System.Collections;
using System.Collections.Specialized;
using System.ComponentModel;
using System.ComponentModel.Design;
using System.Drawing;
using System.Drawing.Design;
using System.Runtime.Serialization;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.Design;
using System.Text;
using System.Runtime.Serialization.Formatters.Soap;
using System.Data;
using System.Data.Common;
using System.Reflection;

namespace Borland.Data.Web
{
	/// <summary>
	/// DBWebDataSource manages Row, State and Changes for DBWebControls
	/// </summary>
   #region DBWebDataSource

	public enum ClientAction
	{
		ecaNone,
		ecaNext,
		ecaPrevious,
		ecaFirst,
		ecaLast,
		ecaDelete,
		ecaInsert,
		ecaApply,
		ecaRefresh,
		ecaUndo,
		ecaUndoAll,
      ecaSetRow,
      ecaDeleteRow,
      ecaCancel
	}

   public enum ErrorHtmlOption
   {
   	logOnSamePage,
      logOnErrorPage,
      logWithErrorEvent
   }

   public enum CascadingDeleteOption
   {
   	noMasterDelete,
      serverCascadeDelete,
      serverNoForeignKey
	}

	public enum CascadingUpdateOption
	{
		noMasterKeyUpdate,
      serverCascadeUpdate,
      serverNoForeignKey
   }

   public enum InsertState
   {
      InsertNone,
		InsertStart,
      InsertEnd
   }

   public interface IDBDataSource
   {
   	// Get current row position of Table or viwe
   	int GetCurrentRow(Page page, string TableName);
      // Get current row adjusted for Inserts and deletes: used by DataGrid
      int GetDisplayRow(Page page, string TableName);
      // Get total # of rows in Table or view
      int GetRowCount(Page page, string TableName);
      // Get current row adjusted for Inserts and deletes
      int GetDisplayRowCount(Page page, string TableName);
      // Get the row that was current prior to last scroll
      int GetLastRow(Page page, string TableName);
      // Get the value for a column based on current row position of Table
		Object GetColumnValue(Page page, string TableName, string ColumnName);
		Object GetColumnValue(Page page, string TableName, string ColumnName, out Type DataType);
		// Get the value for a DBWebAggregateControl
      Object GetAggregateValue(Page page, string TableName, string ColumnName, AggType aggType, bool ignoreNullValues);
      // Get the DataSource: DataSet, DataView, or DataTable
		Object GetDataSource(Page page);
	  	string GetDataSourceName(Page page);
		// Get the Table or view referred to by a TableName
		// detail tables are returned only with the rows that match parent key
		Object GetTableOrView(Page page, string TableName);
		// Get the Table or view referred to by a TableName;
      // if bLimitChildRows is false, entired detail table is returned,
      // regardless of parent key
		bool IsDataBound(string TableName);
      // have changes been made by this client for Table TableName
      bool HasDelta(Page page, string TableName);
		// get any errors as a DataGrid
		bool ChangesCached {get;}
		ErrorHtmlOption ErrorOption{get;}
		string GetErrorHtml(Page page, string TableName);
												      // get any warnings as a DataGrid
      string GetWarningHtml(Page page, string TableName);
      // control management
      void AddControl(WebControl control);
      void RemoveControl(WebControl control);
      void DeleteUserXmlFile(Page page);
      bool HasDetailRecords(Page page, string TableName);
      void RegisterNextControl(WebControl control, string tableName);
		void RegisterPreviousControl(WebControl control, string tableName);
		void RegisterFirstControl(WebControl control, string tableName);
		void RegisterLastControl(WebControl control, string tableName);
		void RegisterInsertControl(WebControl control, string tableName);
		void RegisterDeleteControl(WebControl control, string tableName);
		void RegisterUpdateControl(WebControl control, string tableName);
		void RegisterCancelControl(WebControl control, string tableName);
		void RegisterApplyControl(WebControl control, string tableName);
		void RegisterRefreshControl(WebControl control, string tableName);
		void RegisterUndoControl(WebControl control, string tableName);
		void RegisterUndoAllControl(WebControl control, string tableName);
		void RegisterGoToControl(WebControl ValueControl, WebControl SubmitControl, string tableName);
		void RegisterLocateControl(string KeyFields, ArrayList KeyValueControls, WebControl SubmitControl, string TableName);
		void RegisterLocateControl(string KeyFields, ArrayList KeyValueControls, WebControl SubmitControl, string TableName, bool CaseInsensitive);
		void RegisterLocateControl(string KeyFields, ArrayList KeyValueControls, WebControl SubmitControl, string TableName, bool CaseInsensitive, bool PartialKey);
		void SetNavigationControls(Page page, NameValueCollection postCollection);
		bool HasApplyEvent();
	  // get row # of first parent for a Table, -1 if table is itself the first parent.
		int GetFirstParentRow(Page page, string TableName);
		// get row # of parent for a Table, -1 if table is itself the first parent
		int GetParentRow(Page page, string TableName);
	}

	public interface IDBDataSourceDesign
	{
		DataSet DataSetFromDataSource(object o);
		bool InitDataMemberList(ITypeDescriptorContext context, System.Windows.Forms.ListBox lb, string oldValue, ref int oldColumnIndex);
		bool InitColumnList(System.Windows.Forms.ListBox lb, Object ADBObject,
													ArrayList ExcludedTypes, ArrayList ValidTypes, string oldValue, out int oldColumnIndex,
													bool IsAggregateControl, AggType AggregateType);
		Object CheckExpression(Page page, string Expression);
		bool CheckColumnName(Page page, Object ADBObject, string ColumnName);
		Object GetDBObject(string DataMember);
		bool UpdateParentControl(IDBWebDataLink webControl, ComponentChangedEventArgs ce);
		eRemoveBindingType UpdateControlForRemoved(IDBWebDataLink webControl, ComponentEventArgs  ce);
	}


   public interface IDBPostStateManager
	{
	  // Get current row unadjusted for Inserts and deletes
	  void SetCurrentRow(Page page, string TableName, int iRow);
	  void AddKeyFields(Page page, Object ATableOrView, string TableName,
									DataRow dr, int iRow);
	}

	public interface IPageStateManager
	{
	  ArrayList GetErrors(Page page);
	  ArrayList GetWarnings(Page page);
	  void DoOnError(Page page);
	  bool SetChangedValues(Page page, NameValueCollection postCollection,
										WebControl control);
   }
   
   // access to protected properties for DBWebControlPageState
	public interface IDBPageStateManager : IPageStateManager
   {
	  int IndexOfTable(string tableName);
	  DataSet DataSetFromDataSource(object o);
	  bool IsDetailTable( string TableName );
	  string FirstParent(string TableName);
	  bool UsesHardDeletes(Page page, string TableName);
	  DataRelation GetRelation(Page page, string ParentTableName, string ChildTableName);
	  string ParentTableNameForChildTable(string TableName);
	  bool IsParentOfChild(string childTable, string possibleParent);
	  int GetPhysicalRowCount(Page page, string TableName);
	  void ClearSessionChanges(Page page);
	  void DoOnApplyChanges(Page page);
	  void DoOnAutoApplyChanges(Page page);
	  void DoOnRefresh(Page page);
	  void DoOnScroll(string TableName, int currentRow, int priorRow);
	  void UpdateTables(Page page, ArrayList tables, NameValueCollection changes);
	  int GetDeleteCountFromSession( Page page, string TableName, int iToRow );
	  int GetInsertCountFromSession( Page page, string TableName, int iToRow );
	  void GetConstraintColumnsForParent(string TableName, out DataColumn[] parentConstraintColumns,
													out DataColumn[] childConstraintColumns);
	  void LoadDataSetFromXMLFile(Page page, bool DataSetLoaded);
	  bool HasAutoApplyEvent();
     void RemoveLastChange(Page page);
     Object GetTableOrView(Page page, string TableName, bool bLimitChildRows,
                           bool DontUseCache, bool ForeignKeyCheck);
	  bool HasDuplicateKey(Page page, Object ATableOrView, DataColumn column, Object value);
		// fourth argument: don't save results
	}

	#region LocateObject
	public class LocateObject
   {
		private string FKeyFields;
		private string FTableName;
		private ArrayList FValueControls;
		private WebControl FSubmitControl;
		private bool FCaseInsensitive;
		private bool FPartialKey;
		public LocateObject(string keyFields, ArrayList valueControls,
						   WebControl submitControl, string tableName,
						   bool caseInsensitive, bool partialKey)
		{
		 FTableName = tableName;
		 FKeyFields = keyFields;
		 FValueControls = valueControls;
		 FSubmitControl = submitControl;
		 FCaseInsensitive = caseInsensitive;
		 FPartialKey = partialKey;
		}
	  public string KeyFields
	  {
		 get
		 {
			return FKeyFields;
		 }
	  }
	  public string TableName
	  {
         get
         {
            return FTableName;
         }
      }
      public ArrayList ValueControls
      {
         get
         {
            return FValueControls;
         }
      }
      public WebControl SubmitControl
      {
         get
         {
            return FSubmitControl;
         }
      }
      public bool CaseInsensitive
      {
         get
         {
            return FCaseInsensitive;
         }
      }
      public bool PartialKey
      {
         get
         {
            return FPartialKey;
         }
      }
   }

	#endregion LocateObject


   [ToolboxItemFilter("System.Web.UI"),
   ToolboxBitmap(typeof(Borland.Data.Web.DBWebDataSource),
   "Borland.Data.Web.DBWebDataSource.bmp"),
	Designer("Borland.Data.Web.DBWebDataSourceDesigner")]
   public class DBWebDataSource: MarshalByValueComponent, IDBDataSource, IDBDataSourceDesign, IDBPostStateManager, ISerializable, IPageStateManager, IDBPageStateManager, ISupportInitialize, System.ComponentModel.IListSource
	{
	  public const string IdentPrefix = "DBWid_";
	  protected const string sBorChildDs = "BorlandChildDataSet";

     private CascadingDeleteOption FCascadeDeletes;
     private CascadingUpdateOption FCascadeUpdates;
	  protected Object FDataSource;
	  protected DBWebControlCollection controls;
	  protected PageStateManagerCollection pageStateManagerCollection;
	  protected ArrayList FRelatedTables;
//	  protected ArrayList FTableKey;
	  protected ArrayList FSortColumns;
	  protected ArrayList FTableParentKey;

	  protected Color FErrorDlgBorderColor;
	  protected Color FErrorDlgForeColor;
	  protected Color FErrorDlgBackColor;
	  protected Unit FErrorDlgBorderWidth;
	  protected WebControl FRowStateManager;
	  protected bool FAutoRefresh;
	  // by default, ":_ctrl"
	  private string FAspGridId;

	  private ErrorHtmlOption FErrorOption;
     // XML Caching
     private bool FXMLLoaded;
     private string FXMLFileName;
	  private string FXSDSchemaFile;
	  private bool FAutoUpdateCache;
	  private bool FUseUniqueFileName;
	  private bool FRefreshRequested;
     // Is DataSet loaded from elsewhere (e.g. DBServer)
     //   prior to attempting to get from cached xml?
     private bool FDataSetPreLoaded;
	  private NameValueCollection FNavigationControls;
     private ArrayList FGoToListboxes;
	  private ArrayList FLocateControlList;
	  private string FDataSourceName;


	public DBWebDataSource(): base()
	{
		controls = new DBWebControlCollection();
		FRowStateManager = null;
		FRelatedTables = new ArrayList();
//		FTableKey = new ArrayList();
		FSortColumns = new ArrayList();
		FTableParentKey = new ArrayList();
		pageStateManagerCollection = new PageStateManagerCollection();
		OnApplyChangesRequest = null;
		OnAutoApplyRequest = null;
		OnGetPostCollection = null;
		OnAfterSetChanges = null;
		OnError = null;
		FErrorDlgBorderColor = System.Drawing.Color.Red;
		FErrorDlgBackColor = System.Drawing.Color.Azure;
		FErrorDlgForeColor = System.Drawing.Color.Black;
		FErrorDlgBorderWidth = new Unit(8);
		FAutoRefresh = false;
		FAspGridId = DBWebConst.sGridColumnID;
		FErrorOption = ErrorHtmlOption.logOnErrorPage;
		FNavigationControls = new NameValueCollection();
		FGoToListboxes = new ArrayList();
		FLocateControlList = new ArrayList();
		FDataSourceName = null;
	}

		#region ErrorDialog

		[LocalizableCategoryAttribute("ErrorDlg")]
      [LocalizableDescriptionAttribute("ErrorDlgBorderColor")]
      public System.Drawing.Color ErrorDlgBorderColor
      {
      	get
         {
         	return FErrorDlgBorderColor;
         }
      	set
         {
         	FErrorDlgBorderColor = value;
         }
		}

		[LocalizableCategoryAttribute("ErrorDlg"),
		DefaultValue(ErrorHtmlOption.logOnErrorPage)]
				[LocalizableDescriptionAttribute("ErrorOption")]
		public ErrorHtmlOption ErrorOption
		{
			get
			{
				return FErrorOption;
			}
			set
			{
				FErrorOption = value;
         }
      }

		[LocalizableCategoryAttribute("ErrorDlg")]
      [LocalizableDescriptionAttribute("ErrorDlgBorderWidth")]
      public Unit ErrorDlgBorderWidth
      {
      	get
         {
         	return FErrorDlgBorderWidth;
         }
      	set
         {
         	FErrorDlgBorderWidth = value;
         }
      }

		[LocalizableCategoryAttribute("ErrorDlg")]
      [LocalizableDescriptionAttribute("ErrorDlgBackColor")]
      public System.Drawing.Color ErrorDlgBackColor
      {
      	get
         {
         	return FErrorDlgBackColor;
         }
      	set
         {
         	FErrorDlgBackColor = value;
         }
      }

		[LocalizableCategoryAttribute("ErrorDlg")]
      [LocalizableDescriptionAttribute("ErrorDlgForeColor")]
      public System.Drawing.Color ErrorDlgForeColor
      {
      	get
         {
         	return FErrorDlgForeColor;
         }
      	set
         {
         	FErrorDlgForeColor = value;
         }
      }

	  #endregion ErrorDialog

		#region ISupportsInitialize and IInitializable

      void ISupportInitialize.BeginInit()
      {  // Previously initializing DataSet, which is wrong;
         // the Form already takes care of this.
      }

      void ISupportInitialize.EndInit()
		{
			if( !ClassUtils.IsEmpty(FXSDSchemaFile) || !ClassUtils.IsEmpty(FXMLFileName) )
			{
				DataSet ds = DataSetFromDataSource(FDataSource);
				if( ds != null )
					ds.Relations.Clear();
			}
      }

      void ISerializable.GetObjectData(SerializationInfo info, StreamingContext context)
      {
         if( FDataSource != null && FDataSource is ISerializable)
         	(FDataSource as ISerializable).GetObjectData(info, context);
      }

      IList IListSource.GetList()
      {
			if( FDataSource  != null )
				if( FDataSource is IListSource )
					return (FDataSource as IListSource).GetList();
			return null;
		}

		bool IListSource.ContainsListCollection
		{
			get
			{
				if( FDataSource  != null )
					if( FDataSource is IListSource)
						return (FDataSource as IListSource).ContainsListCollection;
				return false;
			}
		}
	  #endregion ISupportsInitialize and IInitializable

		#region IDBPostStateManager

   	void IDBPostStateManager.SetCurrentRow(Page page, string TableName, int iRow)
      {
      	GetPageStateManager(page).setCurrentRow(TableName, iRow);
      }

		void IDBPostStateManager.AddKeyFields(Page page, Object ATableOrView, string TableName,
      								DataRow dr, int iRow)
	   {
		   addKeyFields(page, ATableOrView, TableName, dr, iRow);
	   }

		#endregion

		#region IDBDataSourceDesign

		eRemoveBindingType IDBDataSourceDesign.UpdateControlForRemoved(IDBWebDataLink webControl, ComponentEventArgs ce)
		{
			eRemoveBindingType eVal = eRemoveBindingType.erbtNone;
			if( webControl != null )
			{
				DBWebDataSource ds = this as DBWebDataSource;
				if( ce.Component == ds )
					eVal = eRemoveBindingType.erbtAll;
				else if( webControl.DBDataSource.GetDataSource(null) != null )
				{
					Object DsDs = webControl.DBDataSource.GetDataSource(null);
					if( DsDs == ce.Component )
					{
						DU.SetPropertyValue(webControl.DBDataSource, "DataSource", null);
						eVal = eRemoveBindingType.erbtTablesAndColumns;
					}
					else if( ce.Component is DataAdapter )
					{
						try
						{
							DataSet AdDs = DU.GetPropertyValue(ce.Component, "DataSet") as DataSet;
							if( AdDs != null && AdDs == DsDs )
							{
								DU.SetPropertyValue(webControl.DBDataSource, "DataSource", null );
								eVal = eRemoveBindingType.erbtTablesAndColumns;
							}
						}
						catch
						{
							// ignore exceptions, as might occur if there is no "DataSet" property
						}
					}
					else if( ce.Component is DataView )
					{
						DataTable table = (ce.Component as DataView).Table;
						if( (table != null) && (table.DataSet != null) )
						{
							if( table.DataSet == DsDs && ce.Component == DsDs )
							{
								DU.SetPropertyValue(webControl.DBDataSource, "DataSource", null );
								eVal = eRemoveBindingType.erbtTablesAndColumns;
							}
						}
					}
				}
			}
			return eVal;
		}
		bool IDBDataSourceDesign.UpdateParentControl(IDBWebDataLink webControl, ComponentChangedEventArgs ce)
		{
			DBWebDataSource ds = this as DBWebDataSource;
			if( ce.Component == null || ce.Member == null || ClassUtils.IsEmpty(ce.Member.Name) )
				return false;
			string propertyName = ce.Member.Name;
			if( ds == ce.Component || this.DataSource == ce.Component )
			{
				if( ds == ce.Component && propertyName == "Name" )
				{
					object TableName = DU.GetPropertyValue(webControl, DBTypes.sTableName );
					DU.SetPropertyValue(webControl, DBTypes.sDBDataSource, ce.Component );
					if( TableName != null )
					{
						DU.SetPropertyValue(webControl, DBTypes.sTableName, TableName);
					}
				}
				if( ds == ce.Component && propertyName == "UseUniqueFileName")
					if( Convert.ToBoolean(ce.NewValue) == true )
						DU.SetPropertyValue(ds, "AutoUpdateCache", true );

				return true;
			}
			else if (ce.Component is DataView )
			{
				DataView dv = ce.Component as DataView;
				if( ds.DataSource != null && ds.DataSource == dv )
					return true;
			}
			else if (ce.Component is DataTable )
			{
				DataTable tbl = ce.Component as DataTable;
				if( ds.DataSource != null )
				{
					if( ds.DataSource == tbl )
					{
						DU.SetPropertyValue(webControl, DBTypes.sTableName, tbl.TableName);
							return true;
					}
					else if( ds.DataSource == tbl.DataSet )
					{
						if( ds.DataSource is DataSet && !ClassUtils.IsEmpty(webControl.TableName) )
						{
							DataSet dataSet = ds.DataSource as DataSet;
							if( !ClassUtils.IsEmpty(Convert.ToString(ce.OldValue)) && webControl.TableName == Convert.ToString(ce.OldValue) )
									DU.SetPropertyValue(webControl, DBTypes.sTableName, tbl.TableName);
						}
						return true;
					}
				}
			}
			else if( ce.Component is DataAdapter )
			{
				DataAdapter adapter = ce.Component as DataAdapter;
				DataSet DaDs = DU.GetPropertyValue(adapter, "DataSet") as DataSet;
				if( DaDs != null && ds.DataSource != null && DaDs == ds.DataSource )
				{
					return true;
				}
			}
			else if( propertyName == "active" )
			   // possibly unneeded refreshes, but harmless
				return true;
			return false;
		}
                            
		bool IDBDataSourceDesign.InitDataMemberList(ITypeDescriptorContext context, System.Windows.Forms.ListBox lb, string oldValue, ref int oldColumnIndex)
      {
         bool bFound = false;
         lb.Items.Clear();
         oldColumnIndex = -1;
			DataSet ds = DataSetFromDataSource(FDataSource);
         if( ds != null)
         {
            for( int i = 0; i < ds.Tables.Count; i++ )
            {
               lb.Items.Add(ds.Tables[i].TableName);
               if( ds.Tables[i].TableName == oldValue )
               {
                  oldColumnIndex = i;
                  lb.SelectedIndex = i;
                  bFound = true;
               }
            }
            if( !bFound )
               lb.SelectedIndex = 0;
         }
         return lb.Items.Count > 0;
      }

      bool IDBDataSourceDesign.InitColumnList(System.Windows.Forms.ListBox lb, Object ADBObject,
                                       ArrayList ExcludedTypes, ArrayList ValidTypes, string oldValue, out int oldColumnIndex,
                                       bool IsAggregateControl, AggType AggregateType)
      {
			bool bFound = false;
         int iExcluded = 0;
         lb.Items.Clear();
         oldColumnIndex = -1;
         bool bAdd;
         if(ADBObject != null && ADBObject is DataTable)
         {
            DataTable dataTable = ADBObject as DataTable;
            for( int i = 0; i < dataTable.Columns.Count; i++ )
            {
               bAdd = IsAggregateControl && ClassUtils.CheckColumnTypeForAggregate(dataTable.Columns[i], AggregateType);
               if( !IsAggregateControl )
                  bAdd = ClassUtils.IsValidType(ValidTypes, dataTable.Columns[i].DataType.FullName) &&
                     !ClassUtils.Excluded(ExcludedTypes, dataTable.Columns[i].DataType.FullName);
               if( bAdd )
               {
                  lb.Items.Add(dataTable.Columns[i].ColumnName);
                  if( dataTable.Columns[i].ColumnName == oldValue )
                  {
                     lb.SelectedIndex = i - iExcluded;
                     oldColumnIndex = lb.SelectedIndex;
                     bFound = true;
                  }
               }
               else
                  iExcluded++;
            }
         }
         if( !bFound && lb.Items.Count > 0 )
            lb.SelectedIndex = 0;
         return lb.Items.Count > 0;
      }

		DataSet IDBDataSourceDesign.DataSetFromDataSource(object o)
      {
         return DataSetFromDataSource(o);
      }
      Object IDBDataSourceDesign.GetDBObject(string DataMember)
      {
         Object o = (this as IDBDataSource).GetTableOrView(null, DataMember);
         if( o is DataTable )
            return (o as DataTable);
         else if ( o is DataView )
            return (o as DataView).Table;
         return null;
      }

		bool IDBDataSourceDesign.CheckColumnName(Page page, Object ADBObject, string ColumnName)
      {
         if( ADBObject != null )
         {
            DataTable table = ADBObject as DataTable;
         	DataColumnCollection columns = table.Columns;
	         if( columns != null )
   	      {
      	   	for( int i = 0; i < columns.Count; i++ )
         	   	if( columns[i].ColumnName == ColumnName )
            	   	return true;
            }
         }
         return false;
      }

      Object IDBDataSourceDesign.CheckExpression(Page page, string Expression)
      {
         Object o = (this as IDBDataSource).GetDataSource(page);
         DataSet ds = null;
         if( o is DataSet )
         	ds = o as DataSet;
         else if( o is DataView )
         	ds = (o as DataView).Table.DataSet;
         else if( o is DataTable )
         	ds = (o as DataTable).DataSet;
         if( ds != null )
         {
            if( ClassUtils.IsDesignTime(page) && !ClassUtils.IsEmpty((this as DBWebDataSource).XMLFileName) )
            {
               (this as IDBPageStateManager).LoadDataSetFromXMLFile(page, false);
            }
        	   for( int i = 0; i < ds.Tables.Count; i++ )
            {
            	if( ds.Tables[i].TableName == Expression )
               {
               	return ds.Tables[i];
               }
            }
            return null;
         }
         return null;
      }

		#endregion

		#region IDBDataSource

		int IDBDataSource.GetParentRow(Page page, string TableName)
		{
			DataTable table = ParentTableForChildTable(TableName);
			if( table == null )
				return -1;
			else
				return GetPageStateManager(page).getCurrentRow(table.TableName);
		}

		int IDBDataSource.GetFirstParentRow(Page page, string TableName)
		{
			return GetPageStateManager(page).getCurrentRow(FirstParent(TableName));
		}


		private System.Web.UI.WebControls.ListControl GetGoToListBox(string ID)
		{
			for( int i = 0; i < FGoToListboxes.Count; i++ )
				if( (FGoToListboxes[i] as System.Web.UI.WebControls.ListControl).ID == ID )
					return (FGoToListboxes[i] as System.Web.UI.WebControls.ListControl);
			return null;
      }

	  private bool SetGoToControl(Page page, NameValueCollection postCollection, string Key, string Value)
	  {
		 int index = Key.IndexOf(DBWebConst.Splitter);
		 string Key1 = Key.Substring(0, index);
		 string Key2 = Key.Substring(index + 1);
		 if( postCollection[Key2] != null )
		 {
			if( Key1 == Key2 )
			{
					System.Web.UI.WebControls.ListControl lb = GetGoToListBox(Key1);
					if( lb != null )
					{  // if GOTO control is a listbox, set to selected Index
						for( int i = 0; i < lb.Items.Count; i++ )
						{
							if( lb.Items[i].ToString() == postCollection[Key1] )
							{
								postCollection.Add(GetPageStateManager(page).GetFullPageName() + Value, Convert.ToString(i));
								return true;
							}
						}
			   }
			}
			if( ClassUtils.IsNumber(postCollection[Key1]) )
			{  // if GOTO control is TextBox, set to its numeric value
			   postCollection.Add(GetPageStateManager(page).GetFullPageName() + Value, postCollection[Key1]);
			   return true;
			}
		 }
		 return false;
	  }

	  private bool SetLocateControls(Page page, NameValueCollection postCollection)
	  {
		 LocateObject locateObj;
		 for( int i = 0; i < FLocateControlList.Count; i++ )
		 {
			locateObj = FLocateControlList[i] as LocateObject;
			if( postCollection[locateObj.SubmitControl.ID] != null )
			{
			   ArrayList KeyValues = new ArrayList();
			   for( int j = 0; j < locateObj.ValueControls.Count; j++ )
				  KeyValues.Add(postCollection[(locateObj.ValueControls[j] as WebControl).ID]);
			   int iRow = Locate(page, locateObj.TableName, locateObj.KeyFields,
								 KeyValues, locateObj.CaseInsensitive,
								 locateObj.PartialKey);
			   if( iRow >= 0 )
				  postCollection.Add(GetPageStateManager(page).GetFullPageName() + locateObj.TableName + DBWebConst.Splitter + DBWebConst.sSetRow, Convert.ToString(iRow));
			   return true;
            }
         }
         return false;
      }

      void IDBDataSource.SetNavigationControls(Page page, NameValueCollection postCollection)
      {
         if( SetLocateControls(page, postCollection) )
            return;
         string Key;
         string Value;
         for( int i = 0; i < FNavigationControls.Count; i++ )
         {
            Key = FNavigationControls.GetKey(i);
            if( postCollection[Key] != null )
            {
               Value = FNavigationControls[i];
               postCollection.Add(GetPageStateManager(page).GetFullPageName() + Value, "true");
               return;
            }
            else if( Key.IndexOf(DBWebConst.Splitter) > 0 )
            {
			   if( SetGoToControl( page, postCollection, Key, FNavigationControls[i] ) )
                  return;
            }
         }
      }

		bool IDBDataSource.HasDelta(Page page, string TableName)
		{
			if( ClassUtils.IsDesignTime(page) )
				return false;
			return GetDeleteOrInsertCountFromSession(page, TableName, -1, "") > 0;
		}

      private Object GetValue(DataColumn column, DataRow row)
      {
         if( column == null || row.IsNull(column.ColumnName) )
				return null;
			else if( column.DataType.ToString() == TypeLiterals.SystemByteArray )
			{
				byte[] byteBlobData = new byte[0];
				try
				{
					byteBlobData = (byte[])row[column.ColumnName];
					return byteBlobData;
				}
				catch
				{
					//TODO: sometimes getting error here
					return "";
				}
			}
			else if( column.DataType.ToString() == TypeLiterals.SystemCharArray )
			{
				char[] byteBlobData = new char[0];
				try
				{
					byteBlobData = (char[])row[column.ColumnName];
					string Text = new string(byteBlobData);
					if( Text.EndsWith("\0") )
						Text = Text.Substring(0, Text.Length -1);
					return Text;
				}
				catch
				{
					//TODO: sometimes getting error here
					return "";
				}
			}
         else
         	return row[column.ColumnName];
      }

		public Object GetColumnValue(Object table, int iRow, string ColumnName, out Type DataType)
		{
			DataType = null;
			if( iRow >= 0 && table != null)
			{
				if( table != null )
				{
					DataRow row;
					DataColumn column;
					if( table is DataTable )
					{
						if( iRow >= (table as DataTable).Rows.Count )
							return null;
						column = (table as DataTable).Columns[ColumnName];
						DataType = column.DataType;
						row = (table as DataTable).Rows[iRow];
						return GetValue(column, row);
					}
				else if( table is DataView )
				{
				  DataView view = table as DataView;
				  if( iRow >= view.Count )
					  return null;
				  DataType = view.Table.Columns[ColumnName].DataType;
				  return GetValue(view.Table.Columns[ColumnName], view[iRow].Row);
				}
				}
         }
         return null;
      }

      Object IDBDataSource.GetAggregateValue(Page page, string TableName, string ColumnName, AggType aggType, bool ignoreNullValues)
      {
			 return GetPageStateManager(page).GetAggregateValue(TableName, ColumnName, aggType, ignoreNullValues);
		}

		Object IDBDataSource.GetColumnValue(Page page, string TableName, string ColumnName)
		{
			Type DataType = null;
			return (this as IDBDataSource).GetColumnValue(page, TableName, ColumnName, out DataType);
		}
		Object IDBDataSource.GetColumnValue(Page page, string TableName, string ColumnName, out Type DataType)
		{
			DataType = null;
			if( !(this as IDBDataSource).IsDataBound(TableName) || ClassUtils.IsEmpty(ColumnName ))
				return null;
			else
			{
				//Fix for 211533
				int iRow = (this as IDBDataSource).GetDisplayRow(page, TableName);
				if( iRow >= 0 )
				{
					Object table = getTableOrView(page, TableName, true, false, false);
					return GetColumnValue(table, iRow, ColumnName, out DataType);
            }
         }
         return null;
      }

      int IDBDataSource.GetRowCount(Page page, string TableName)
      {
			return GetPageStateManager(page).GetRowCount(TableName);
		}
      int IDBDataSource.GetDisplayRowCount(Page page, string TableName)
      {
      	int iCount = GetPageStateManager(page).GetRowCount(TableName);
         if( iCount > 0 && !IsDetailTable(TableName))
         	return iCount - GetPageStateManager(page).GetDeleteCount(TableName, -1);
         else
           return iCount;
      }
   	int IDBDataSource.GetCurrentRow(Page page, string TableName)
      {
         return GetPageStateManager(page).getCurrentRow(TableName);
      }
   	int IDBDataSource.GetDisplayRow(Page page, string TableName)
      {
         int iRow = GetPageStateManager(page).getCurrentRow(TableName);
         if( iRow > 0 )
         	return iRow - GetPageStateManager(page).GetDeleteCount(TableName, iRow);
         else
         	return iRow;
      }
   	int IDBDataSource.GetLastRow(Page page, string TableName)
      {
      	return GetPageStateManager(page).getLastRow(TableName);
      }
      bool IDBDataSource.IsDataBound(string TableName)
		{
			if( DataSource != null && (DataSource is DataView ||
					DataSource is DataTable || (TableName != null && (IndexOfTable(TableName) >= 0) ) ) )
				return true;
			return false;
		}

      bool IDBDataSource.HasApplyEvent()
      {
      	return OnApplyChangesRequest != null;
      }
      
		Object IDBDataSource.GetTableOrView(Page page, string TableName)
		{
			return getTableOrView(page, TableName, true, false, true);
		}

		void IDBDataSource.AddControl(WebControl control)
		{
			if(controls.IndexOf(control) < 0)
			{
				controls.Add(control);
				SetDataSourceName(control.Page);
				if( !ClassUtils.IsDesignTime(control.Page) )
					control.Page.Session[DBWebConst.sDSControl + GetPageStateManager(control.Page).GetFullPageName() + control.ID] = FDataSourceName;
				if( control is DBWebGrid )
				{
					DBWebGrid grid = control as DBWebGrid;
					if( !ClassUtils.IsDesignTime(control.Page) && grid.Columns != null )
						control.Page.Session[control.ID + DBWebConst.sGridColumnCount] = grid.Columns.Count;
				}
			}
		}
		void IDBDataSource.RemoveControl(WebControl control)
		{
			if(controls.IndexOf(control) >= 0)
			{
				controls.Remove(control);
			}
		}

		string IDBDataSource.GetDataSourceName(Page page)
		{
			return GetDataSourceName(page);
		}

		Object IDBDataSource.GetDataSource(Page page)
		{
			Object o = null;
			if( FAutoRefresh || (page == null) || ClassUtils.IsDesignTime(page) )
				o = FDataSource;
			else if( page.Session[GetDataSourceName(page) + DBWebConst.sDataSource] == null )
				o = FDataSource;
			else
			o = page.Session[GetDataSourceName(page) + DBWebConst.sDataSource] as Object;
         if( ClassUtils.IsDesignTime(page) )
         	return o;
         return ClassUtils.CopyDataSource(o);
      }

		ErrorHtmlOption IDBDataSource.ErrorOption
		{
			get
			{
				return FErrorOption;
			}
		}

		bool IDBDataSource.ChangesCached
		{
			get
			{
				if( FAutoRefresh && !ClassUtils.IsEmpty(FXMLFileName) )
					return false;
				else if( OnAutoApplyRequest != null && OnAutoApplyRequest == null)
					return false;
				return true;
			}
		}



		string IDBDataSource.GetErrorHtml(Page page, string TableName)
      {
         if( ClassUtils.IsDesignTime(page) || TableName == null || TableName == "" )
         	return null;
         else
      		return GetPageStateManager(page).ErrorHtml(TableName);
      }

      string IDBDataSource.GetWarningHtml(Page page, string TableName)
      {
         if( ClassUtils.IsDesignTime(page) || TableName == null || TableName == "" )
         	return null;
         else
      		return GetPageStateManager(page).WarningsHtml(TableName);
      }
	  void IDBDataSource.RegisterLocateControl(string KeyFields, ArrayList KeyValueControls, WebControl SubmitControl, string TableName)
	  {
		 (this as IDBDataSource).RegisterLocateControl(KeyFields, KeyValueControls, SubmitControl, TableName, false, false);
	  }
	  void IDBDataSource.RegisterLocateControl(string KeyFields, ArrayList KeyValueControls, WebControl SubmitControl, string TableName, bool CaseInsensitive)
	  {
		 (this as IDBDataSource).RegisterLocateControl(KeyFields, KeyValueControls, SubmitControl, TableName, CaseInsensitive, false);
	  }
	  void IDBDataSource.RegisterLocateControl(string KeyFields, ArrayList KeyValueControls, WebControl SubmitControl, string TableName, bool CaseInsensitive, bool PartialKey)
	  {
		 FLocateControlList.Add(new LocateObject(KeyFields, KeyValueControls, SubmitControl, TableName, CaseInsensitive, PartialKey ) );
      }

      void IDBDataSource.RegisterApplyControl(WebControl control, string tableName)
      {
         FNavigationControls.Add(control.ID, tableName + DBWebConst.Splitter + DBWebConst.sApplyText);
      }
      void IDBDataSource.RegisterRefreshControl(WebControl control, string tableName)
      {
         FNavigationControls.Add(control.ID, tableName + DBWebConst.Splitter + DBWebConst.sRefreshText);
      }
      void IDBDataSource.RegisterNextControl(WebControl control, string tableName)
      {
         FNavigationControls.Add(control.ID, tableName + DBWebConst.Splitter + DBWebConst.sNextText);
      }
      void IDBDataSource.RegisterPreviousControl(WebControl control, string tableName)
      {
         FNavigationControls.Add(control.ID, tableName + DBWebConst.Splitter + DBWebConst.sPrevText);
      }
      void IDBDataSource.RegisterFirstControl(WebControl control, string tableName)
      {
         FNavigationControls.Add(control.ID, tableName + DBWebConst.Splitter + DBWebConst.sFirstText);
      }
      void IDBDataSource.RegisterLastControl(WebControl control, string tableName)
      {
         FNavigationControls.Add(control.ID, tableName + DBWebConst.Splitter + DBWebConst.sLastText);
      }
      void IDBDataSource.RegisterInsertControl(WebControl control, string tableName)
      {
         FNavigationControls.Add(control.ID, tableName + DBWebConst.Splitter + DBWebConst.sInsertText);
      }
      void IDBDataSource.RegisterDeleteControl(WebControl control, string tableName)
      {
         FNavigationControls.Add(control.ID, tableName + DBWebConst.Splitter + DBWebConst.sDeleteText);
      }
      void IDBDataSource.RegisterUpdateControl(WebControl control, string tableName)
      {
      }
      void IDBDataSource.RegisterCancelControl(WebControl control, string tableName)
      {
         FNavigationControls.Add(control.ID, tableName + DBWebConst.Splitter + DBWebConst.sCancelChange);
      }
      void IDBDataSource.RegisterUndoControl(WebControl control, string tableName)
      {
         FNavigationControls.Add(control.ID, tableName + DBWebConst.Splitter + DBWebConst.sUndoText);
      }
      void IDBDataSource.RegisterUndoAllControl(WebControl control, string tableName)
      {
         FNavigationControls.Add(control.ID, tableName + DBWebConst.Splitter + DBWebConst.sUndoAllText);
      }
      void IDBDataSource.RegisterGoToControl(WebControl ValueControl, WebControl SubmitControl, string tableName)
      {
			FNavigationControls.Add(ValueControl.ID + DBWebConst.Splitter + SubmitControl.ID, tableName + DBWebConst.Splitter + DBWebConst.sSetRow);
			if( (ValueControl.ID == SubmitControl.ID) && (ValueControl is System.Web.UI.WebControls.ListControl ) )
				FGoToListboxes.Add(ValueControl);
		}

		void IDBDataSource.DeleteUserXmlFile(Page page)
		{
			string fileName = UserBasedFileName(page, false);
			if( !ClassUtils.IsEmpty(fileName) &&
						File.Exists(fileName) )
			{
				if( FUseUniqueFileName )
					File.Delete(fileName);
				fileName = ClassUtils.GetChangesFileName(fileName);
				if( File.Exists(fileName) )
					File.Delete(fileName);
			}
			FXMLLoaded = false;
      }

      bool IDBDataSource.HasDetailRecords(Page page, string TableName)
      {
			DataRelation relation = GetRelation(page, TableName, "");
			if( relation == null )
				return false;
			// get child table and see if it has rows.
			object o = getTableOrView(page, relation.ChildTable.TableName, true, false, false);
			// has to be a DataView, as detail tables are only returned in this format
			if( o is DataView )
				return (o as DataView).Count > 0;
			return false;
		}
		#endregion

		#region Page State Manager access

		protected void SetDataSourceName(Page page)
		{
			if( ClassUtils.IsDesignTime(page ) )
				FDataSourceName = this.Site.Name;
			else
			{
				Type t = page.GetType();
				FieldInfo[] fields = t.GetFields(BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic);
				if( fields != null )
				{
					foreach( FieldInfo field in fields )
					{
						Object o = field.GetValue(page);
						if( o != null && o == this )
						{
							FDataSourceName = field.Name;
							break;
						}
					}
				}
				if (FDataSourceName == null)
					FDataSourceName = "_None_";
				FDataSourceName = GetPageStateManager(page).GetFullPageName() + FDataSourceName;
			}
		}
		protected string GetDataSourceName(Page page)
		{
			if( FDataSourceName == null )
				SetDataSourceName(page);
			return FDataSourceName;
		}


		protected PageStateManager GetPageStateManager(Page page)
		{
			PageStateManager psm = pageStateManagerCollection.FindPageStateManager(page);
			if( psm == null )
			{
				psm = new PageStateManager(page, this, FAspGridId);
				pageStateManagerCollection.Add(psm);
			 }
			return psm;
		}
	  #endregion Page State Manager access



		public DataRow[] GetDetailRows(Page page, DataRelation relation)
      {
      	int iRow = GetPageStateManager(page).getCurrentRow(relation.ParentTable.TableName);
      	return relation.ParentTable.Rows[iRow].GetChildRows(relation.RelationName);
      }

	   protected void SetValue(DataColumn column, DataRow row, string value)
      {
         if( column.DataType.ToString() == TypeLiterals.SystemCharArray )
         {
         	Char[] charBlobData = value.ToCharArray();
				row[column.ColumnName] = charBlobData;
			}
         else if( column.DataType.ToString() == TypeLiterals.SystemBoolean )
         {
            if( !ClassUtils.IsEmpty(value) && BdwResources.GetString("TrueValues").ToLower().IndexOf(value.ToLower())>= 0 )
         		row[column.ColumnName] = true;
            else
         		row[column.ColumnName] = false;
         }
         else if( !ClassUtils.IsEmpty(value) && column.DataType.ToString() == TypeLiterals.SystemChar )
         {
            row[column.ColumnName] = Convert.ToChar(value);
         }
         else if( ClassUtils.IsEmpty(value) )
			{
				if( column.AllowDBNull )
         		row[column.ColumnName] = DBNull.Value;
            else  // TODO: need to convert string for different field types!
            	row[column.ColumnName] = value;
         }
         else
			row[column.ColumnName] = value;
		}

		// return the column # that is invalid
		public int InvalidRow(DataRow row, Object table)
		{
			if( table is DataTable )
         {
				for( int i = 0; i < (table as DataTable).Columns.Count; i++ )
				{
					if( (table as DataTable).Columns[i].AllowDBNull == false )
						if( row[i] == DBNull.Value )
							return i;
				}
			}
			return -1;
		}

		public bool IsKeyColumn(Object ATableOrView, int iCol )
		{
			DataTable table = GetTableFromObject(ATableOrView);
			DataColumn[] parentConstraintCols = null;
			DataColumn[] childConstraintCols = null;
			GetConstraintColumnsForParent(table.TableName, out parentConstraintCols, out childConstraintCols);
			if( parentConstraintCols != null )
			{
				for( int i = 0; i < parentConstraintCols.Length; i++ )
					if( parentConstraintCols[i].Ordinal == iCol )
						return true;
			}
			if( childConstraintCols != null )
			{
				for( int i = 0; i < childConstraintCols.Length; i++ )
					if( childConstraintCols[i].Ordinal == iCol )
						return true;
			}
			return false;
		}

		public void SetColumnValue(Object table, int iRow, DataColumn column,
											String value, out bool bRowDropped)
		{
			bRowDropped = false;
			if( iRow >= 0 )
			{
				if( table != null )
            {
            	DataRow row = null;
               if( table is DataTable )
               {
						int iRows = (table as DataTable).Rows.Count;
						row = (table as DataTable).Rows[iRow];
						row.BeginEdit();
						SetValue(column, row, value);
						row.EndEdit();
						if( row.RowState == DataRowState.Added && InvalidRow(row, table) < 0 )
							(table as DataTable).EndLoadData();
						row.AcceptChanges();
						bRowDropped = (table as DataTable).Rows.Count < iRows;
					}
					else if( table is DataView )
					{
						DataView view = table as DataView;
						int iRows = view.Count;
						row = view[iRow].Row;
						row.BeginEdit();
						SetValue(column, row, value);
						row.EndEdit();
						// the EndEdit() in following code will delete any inserted records
						// view[iRow].BeginEdit();
						// view[iRow][column.ColumnName] = row[column.ColumnName];
						// view[iRow].EndEdit();
						// Further, if a row is new, AcceptChanges throws a "row not in table" exception!
						if( view.Count > iRow )
							if( !view[iRow].IsNew )
						row.AcceptChanges();
							bRowDropped = view.Count < iRows;
					}
				}
			}
		}

      protected string FirstParent(string TableName)
      {
         if( FDataSource == null )
         	return null;
         string parentTable = ParentTableNameForChildTable(TableName);
         while( parentTable != null )
         {
         	TableName = parentTable;
         	parentTable = ParentTableNameForChildTable(TableName);
         }
         return TableName;
      }

		[LocalizableCategoryAttribute("DBDataSource"),
		DefaultValue(false)]
                [LocalizableDescriptionAttribute("AutoRefresh")]
		public bool AutoRefresh
		{
      	get
         {
         	return FAutoRefresh;
         }
         set
			{
				FAutoRefresh = value;
			}
		}

		protected void UpdateStateForUserXmlChanges(PageStateManager manager)
		{  // Update UserChangesXml File with any changes just made.
			NameValueCollection changes = ClassUtils.ChangesForTable(manager.GetPage(), "");
			SerializeChanges(manager.GetPage(), changes);
			if( changes.Count > 0 )
			{
				for( int i = 0; i < FRelatedTables.Count; i++ )
				{
					string TableName = FRelatedTables[i].ToString();
					manager.SetCurrentObject(getTableOrView(manager.GetPage(), TableName, false, false, false), TableName);
				}
			}
		}

		#region IPageStateManager
		// this method is where all changes are made prior to rendering any
		// controls.  Call to manager.SetChangedValues() handles the changes.
		bool IPageStateManager.SetChangedValues(Page page, NameValueCollection postCollection,
											WebControl control)
		{
			PageStateManager manager = GetPageStateManager(page);
			// if changed values have already been set , don't set them
			// again.
			bool bRetval = !manager.GetPageFieldsWritten();
			if( control != null )
				FRowStateManager = control;
			if( postCollection.Count > 0 && bRetval)
				if( !manager.GetPostCollectionValuesSet() )
				{
					CheckCurrentRows(page, postCollection);
					if( !DoOnGetPostCollection(postCollection) )
					{
						manager.SetChangedValues(postCollection);
						DoOnAfterSetChanges();
						if( UseXmlChangesFile(page) )
							UpdateStateForUserXmlChanges(manager);
					}
				}
			return bRetval;
		}

		void IPageStateManager.DoOnError(Page page)
		{
			DoOnError(page);
		}
		ArrayList IPageStateManager.GetErrors(Page page)
		{
         return GetPageStateManager(page).Errors;
      }
      ArrayList IPageStateManager.GetWarnings(Page page)
		{
         return GetPageStateManager(page).Warnings;
		}
      #endregion

      #region IDBPageStateManager

		bool IDBPageStateManager.HasDuplicateKey(Page page, Object ATableOrView, DataColumn column, Object value)
      {
         DataTable table = GetTableFromObject(ATableOrView);
         DataColumn[] foreignKeys = GetForeignKeys(page, table.TableName);
         if( foreignKeys != null )
         {
				for( int i = 0; i < foreignKeys.Length; i++ )
				{
               if( foreignKeys[i].Ordinal == column.Ordinal )
               {
                  table.DefaultView.RowFilter = GetFilterForColumn(foreignKeys[i], Convert.ToString(value));
                  try
                  {
                     if( table.DefaultView.Count > 0 )
                        return true;
                  }
                  finally
                  {
                     table.DefaultView.RowFilter = "";
                  }
               }
            }
         }
         return false;
      }

		Object IDBPageStateManager.GetTableOrView(Page page, string TableName, bool bLimitChildRows,
                                 bool DontUseCache, bool ForeignKeyCheck)
		{
			return getTableOrView(page, TableName, bLimitChildRows, DontUseCache, ForeignKeyCheck);
		}

      void IDBPageStateManager.RemoveLastChange(Page page)
      {
         RemoveLastChange(page);
      }

      void IDBPageStateManager.GetConstraintColumnsForParent(string TableName, out DataColumn[] parentConstraintColumns,
													out DataColumn[] childConstraintColumns)
	   {
		   GetConstraintColumnsForParent(TableName, out parentConstraintColumns, out childConstraintColumns);
	   }
	   int IDBPageStateManager.GetDeleteCountFromSession( Page page, string TableName, int iToRow )
	   {
		   return GetDeleteOrInsertCountFromSession(page, TableName, iToRow, DBWebConst.sDbxDelete);
	   }

	   int IDBPageStateManager.GetInsertCountFromSession( Page page, string TableName, int iToRow )
	   {
			return GetDeleteOrInsertCountFromSession(page, TableName, iToRow, DBWebConst.sDbxInsert);
	   }

	   bool IDBPageStateManager.UsesHardDeletes(Page page, string TableName)
	   {
			if( !ClassUtils.IsDesignTime(page) &&
				page.Session[DBWebConst.sHardDeletes + GetPageStateManager(page).GetFullPageName() + TableName] != null )
			return Convert.ToBoolean(page.Session[DBWebConst.sHardDeletes + GetPageStateManager(page).GetFullPageName() + TableName]);
			return false;
		}

		void IDBPageStateManager.DoOnAutoApplyChanges(Page page)
		{
			DoOnApplyChanges(page, OnAutoApplyRequest);
		}
		void IDBPageStateManager.DoOnApplyChanges(Page page)
		{
			DoOnApplyChanges(page, OnApplyChangesRequest);
		}
		void IDBPageStateManager.DoOnRefresh(Page page)
		{
			DoOnRefresh(page);
		}
		void IDBPageStateManager.DoOnScroll(string TableName, int currentRow, int priorRow)
		{
			DoOnScroll(TableName, currentRow, priorRow);
		}
		void IDBPageStateManager.UpdateTables(Page page, ArrayList tables, NameValueCollection changes)
		{
		   UpdateTables(page, tables, changes, true);
		}

	  void IDBPageStateManager.LoadDataSetFromXMLFile(Page page, bool DataSetLoaded)
	  {
		 LoadDataSetFromXMLFile(page, DataSetLoaded);
      }
      void IDBPageStateManager.ClearSessionChanges(Page page)
      {
      	ClearSessionChanges(page);
      }

      int IDBPageStateManager.IndexOfTable(string tableName)
      {
      	return IndexOfTable(tableName);
      }
      DataSet IDBPageStateManager.DataSetFromDataSource(object o)
      {
      	return DataSetFromDataSource(o);
      }
      bool IDBPageStateManager.IsDetailTable( string TableName )
      {
      	return IsDetailTable(TableName);
      }
      string IDBPageStateManager.FirstParent(string TableName)
      {
      	return FirstParent(TableName);
		}
      DataRelation IDBPageStateManager.GetRelation(Page page, string ParentTableName, string ChildTableName)
      {
         return GetRelation(page, ParentTableName, ChildTableName);
      }
      string IDBPageStateManager.ParentTableNameForChildTable(string TableName)
      {
         return ParentTableNameForChildTable(TableName);
      }

	  bool IDBPageStateManager.IsParentOfChild(string childTable, string possibleParent)
	  {
		DataRelation relation = GetRelation(null, "", childTable);
		while( relation != null )
		{
			if( relation.ParentTable.TableName == possibleParent )
				return true;
			relation = GetRelation(null, "", relation.ParentTable.TableName);
		}
		return false;
	  }

	  int IDBPageStateManager.GetPhysicalRowCount(Page page, string TableName)
		{
			object table = getTableOrView(page, TableName, true, false, false);
			if( table is DataView )
				return (table as DataView).Count;
			else if (table is DataTable)
				return (table as DataTable).Rows.Count;
			return -1;
		}

		bool IDBPageStateManager.HasAutoApplyEvent()
		{
			return OnAutoApplyRequest != null;
      }

	  #endregion

      #region Utilitiy methods
      private string GetFilterForColumn(DataColumn column, string Value)
		{
			if( ClassUtils.IsEmpty(Value ) )
				return column.ColumnName +	"= null";
			else if( column.DataType == Type.GetType(TypeLiterals.SystemString) )
            return column.ColumnName + " = '" + Value + "'";
         else
            return column.ColumnName + " = " + Value;
      }
      #endregion
     
      #region Sort and OrderBy methods

      private DataColumnCollection GetColumns(object table)
      {
		   if( table is DataView )
			   return (table as DataView).Table.Columns;
      else
         return (table as DataTable).Columns;
      }

		public ArrayList GetRowValues(object table, int iRow)
		{
			return GetRowValues(table, iRow, false);
		}

		public ArrayList GetRowValues(object table, int iRow, bool ignoreBlobs)
		{
			if( iRow < 0 || iRow >= GetRowCount(table) )
				return null;
			ArrayList rowValues = new ArrayList();
			DataRow row;
			DataColumnCollection columns = GetColumns(table);
			if( table is DataView )
				row = (table as DataView)[iRow].Row;
			else
				row = (table as DataTable).Rows[iRow];
			for( int i = 0; i < columns.Count; i++ )
				if( ignoreBlobs ||
					 (columns[i].DataType != Type.GetType(TypeLiterals.SystemByteArray) &&
					  columns[i].DataType != Type.GetType(TypeLiterals.SystemCharArray) ) )
					rowValues.Add(row[i]);
			return rowValues;
      }

      private DataRow GetRow(object table, int iRow)
      {
         if( table is DataView )
            return (table as DataView)[iRow].Row;
         return (table as DataTable).Rows[iRow];
      }

      private bool RowIsSame(object table, DataRow row, ArrayList values)
      {
	 //Getcolumns will return all columns of the table. 
         //the Values array may not have all columns since in case its a Grid and one of the columns of the table
	 //is a blob field it wouldn't be in the values. So we have to make sure not to check that column then.
         //Fix for 209370
         DataColumnCollection columns = GetColumns(table);
         for( int i = 0; i < columns.Count; i++ )
         {
            string dataType = columns[i].DataType.ToString();
            if (values == null)
              return false;
            if (i < values.Count && !ClassUtils.CompareObjects(row[i], values[i], dataType ))
               return false;
         }
         return true;
      }

      private bool RowIsBeforeValue(object table, DataRow row, ArrayList values, int iSortColumn, string sNewSortValue )
      {
         if( iSortColumn >= 0 )
         {
            int iCompare = String.Compare(row[iSortColumn].ToString(), values[iSortColumn].ToString() );
            if( iCompare > 0 )
               return false;
            else if( iCompare < 0 )
               return true;
         }
         return !RowIsSame(table, row, values);
      }

      public int GetRowCount(object table)
      {
         if( table is DataView )
            return (table as DataView).Count;
         else
            return (table as DataTable).Rows.Count;
      }

      public int GetRowPosition(object table, ArrayList rowValues, int iSortColumn, string sNewSortValue )
      {
         int iNewRow = 0;
         int iRowCount = GetRowCount(table);
         while( iNewRow < iRowCount )
         {
            DataRow row = GetRow(table, iNewRow);
            if( !RowIsBeforeValue(table, row, rowValues, iSortColumn, sNewSortValue ) )
               return iNewRow;
            iNewRow++;
         }
         return 0;
      }

      #endregion Sort and OrderBy methods

      #region Cascade Delete/Insert
		[LocalizableCategoryAttribute("DBDataSource"),
		DefaultValue(CascadingDeleteOption.noMasterDelete)]
      [LocalizableDescriptionAttribute("CascadingDeletes")]
      public CascadingDeleteOption CascadingDeletes
      {
         get
         {
            return FCascadeDeletes;
         }
         set
         {
            FCascadeDeletes = value;
         }
      }


      [LocalizableCategoryAttribute("DBDataSource"),
		DefaultValue(CascadingUpdateOption.noMasterKeyUpdate)]
      [LocalizableDescriptionAttribute("CascadingUpdates")]
      public CascadingUpdateOption CascadingUpdates
      {
         get
         {
            return FCascadeUpdates;
         }
         set
         {
            FCascadeUpdates = value;
         }
      }
      #endregion

      #region CacheFile
      [Editor(typeof(Borland.Data.Web.DBWebSelectXML), typeof(UITypeEditor)),
      LocalizableCategoryAttribute(DBWebConst.sCacheFile),
		DefaultValue(null)]
      [LocalizableDescriptionAttribute("XMLFileName")]
      public string XMLFileName
      {
         get
         {
            return FXMLFileName;
         }
         set
         {
            FXMLFileName = value;
            FXMLLoaded = false;
         }
      }

      [Editor(typeof(Borland.Data.Web.DBWebSelectXML), typeof(UITypeEditor)),
      LocalizableCategoryAttribute(DBWebConst.sCacheFile),
		DefaultValue(null)]
      [LocalizableDescriptionAttribute("XSDFileName")]
      public string XSDSchemaFile
      {
         get
         {
            return FXSDSchemaFile;
         }
         set
         {
            FXSDSchemaFile = value;
            FXMLLoaded = false;
         }
      }

      [LocalizableCategoryAttribute(DBWebConst.sCacheFile),
		DefaultValue(false)]
      [LocalizableDescriptionAttribute("AutoUpdateCache")]
      public bool AutoUpdateCache
      {
         get
         {
            return FAutoUpdateCache;
         }
         set
         {
				FAutoUpdateCache = value;
         }
      }

      [LocalizableCategoryAttribute(DBWebConst.sCacheFile),
		DefaultValue(false)]
      [LocalizableDescriptionAttribute("UseUniqueFileName")]
      public bool UseUniqueFileName
      {
         get
         {
            return FUseUniqueFileName;
         }
         set
         {
            FUseUniqueFileName = value;
         }
      }

      protected string UserBasedFileName(Page page, bool DataSetLoaded)
      {
         if( DataSetLoaded && ClassUtils.IsDesignTime(page))
            return "";
         if( !FUseUniqueFileName || ClassUtils.IsEmpty(FXMLFileName) ||
					ClassUtils.IsDesignTime(page) || ClassUtils.IsEmpty(page.User.Identity.Name))
            return FXMLFileName;
         int extPos = FXMLFileName.LastIndexOf('.');
			if( extPos == 0 )  // no extension?
				return FXMLFileName + "_" + page.User.Identity.Name;
			return FXMLFileName.Substring(0, extPos) + "_" +
							page.User.Identity.Name + FXMLFileName.Substring(extPos);
		}

		protected void ClearDataSet(DataSet dataSet)
		{
			try
			{
				for( int i = 0; i < dataSet.Tables.Count; i++ )
					dataSet.Tables[i].Constraints.Clear();
			}
			catch
			{
				// ignore errors clearing constraints in wrong order.
			}
			dataSet.Relations.Clear();
			dataSet.Tables.Clear();
			dataSet.Clear();
		}

		protected void LoadDataSetFromXMLFile(Page page, bool DataSetLoaded )
		{
			if( (FDataSource == null) || ClassUtils.IsEmpty(FXMLFileName) || FXMLLoaded
						|| (!File.Exists(FXMLFileName) && ClassUtils.IsDesignTime(page)) )
				return;
			FDataSetPreLoaded = DataSetLoaded && FAutoUpdateCache && FUseUniqueFileName;
			DataSet dataSet;
			bool SaveAutoRefresh = FAutoRefresh;
			try
			{
				FAutoRefresh = true;
				dataSet = DataSetFromDataSource(DataSource);
			}
			finally
			{
				FAutoRefresh = SaveAutoRefresh;
			}

			string FileName = UserBasedFileName(page, DataSetLoaded);
			string SchemaFile = FXSDSchemaFile;
			if( FDataSetPreLoaded && dataSet != null && !File.Exists(SchemaFile) )
				dataSet.WriteXmlSchema(SchemaFile);
			// if authentication is on, and this is first time
			// user is running, only base xml file name will exist;
			if( !File.Exists(FileName) && (!DataSetLoaded || ClassUtils.IsDesignTime(page)) )
				FileName = FXMLFileName;
			if( File.Exists(FileName) )
			{
				ClearDataSet(dataSet);
				if( File.Exists(SchemaFile) )
					dataSet.ReadXmlSchema(SchemaFile);
				try
				{
					// in case xsd file contained rows.
					for( int i = 0; i < dataSet.Tables.Count; i++ )
						dataSet.Tables[i].Rows.Clear();
					dataSet.ReadXml(FileName);
					dataSet.AcceptChanges();
				}
				catch( Exception ex)
				{
					throw new Exception(BdwResources.GetString("CantReadXmlFile") + " " +
									FileName + ", " + ex.Message);
				}
				FXMLLoaded = true;
				PageStateManager manager = GetPageStateManager(page);
				manager.InitDataSet(dataSet);
				for( int i = 0; i < dataSet.Tables.Count; i++ )
					if( manager.getCurrentRow(dataSet.Tables[i].TableName) < 0 )
						if( dataSet.Tables[i].Rows.Count >= 0 )
							manager.setCurrentRow(dataSet.Tables[i].TableName, 0 );

			}
			else
			{
				if( FDataSetPreLoaded && FileName != FXMLFileName )
					dataSet.WriteXml(FileName);
				if( !DataSetLoaded )
					dataSet.Clear();
			}
		}
	  #endregion

		#region table access methods

	  public DataTable GetTableFromObject(object o)
      {
         if( o is DataView )
			   return (o as DataView).Table;
         return o as DataTable;
      }

      protected DataSet DataSetFromDataSource(object o)
      {
      	if( o is DataSet )
         	return o as DataSet;
         else if ( o is DataTable )
         	return (o as DataTable).DataSet;
         else if( o is DataView )
         {
         	if( (o as DataView).Table != null )
         		return (o as DataView).Table.DataSet;
            return null;
         }
         else
         	return null;
      }

		[Editor(typeof(Borland.Data.Web.DataSourceEditor), typeof(UITypeEditor)),
		LocalizableCategoryAttribute("DBDataSource"),
		DefaultValue(null)]
      [LocalizableDescriptionAttribute("DataSource")]
		public Object DataSource
		{
			get
			{
				return FDataSource;
			}
			set
			{
				FDataSource = value;
				FXMLLoaded = false;
			}
		}

		protected void CheckCurrentRows(Page page, NameValueCollection postCollection)
		{
			try
			{
				DataSet ds = DataSetFromDataSource(FDataSource);
				FRefreshRequested = ClassUtils.RefreshRequested(postCollection, ds, GetDataSourceName(page));
				for( int i = 0; i < ds.Tables.Count; i++ )
				{
					PageStateManager manager = GetPageStateManager(page);
					if( !IsDetailTable(ds.Tables[i].TableName) )
					{
						int iRow = manager.getCurrentRow(ds.Tables[i].TableName);
						if( iRow >= 0 )
						{
							ArrayList expectedObject = GetPageStateManager(page).GetCurrentObject(ds.Tables[i].TableName) as ArrayList;
							if( expectedObject != null )
							{
								Object TableOrView = getTableOrView(page, ds.Tables[i].TableName, false, false, false);
								if( !CheckCurrentRow(page, expectedObject, ds.Tables[i], TableOrView, iRow ) )
								{
									FindCurrentObject(page, expectedObject, ds.Tables[i], TableOrView, ds.Tables[i].TableName);
									page.Session[DBWebConst.sInvalidRow + manager.GetFullPageName() + ds.Tables[i].TableName] = true;
								}
							}
						}
					}
				}
			}
			catch
			{
				// ignore errors here
			}
		}

		protected bool CheckCurrentRow(Page page, ArrayList lastRow, DataTable table,
												 Object TableOrView, int iRow)
		{
			for(int i = 0; i < table.Columns.Count; i++ )
			{
				if( table.Columns[i].DataType != Type.GetType(TypeLiterals.SystemByteArray) &&
					 table.Columns[i].DataType != Type.GetType(TypeLiterals.SystemCharArray) )
				{
					Type DataType;
					if( !ClassUtils.CompareObjects( GetColumnValue(TableOrView, iRow,
														table.Columns[i].ColumnName, out DataType),
														lastRow[i], table.Columns[i].DataType.ToString()) )
						return false;
				}
			}
			return true;
		}

		protected void FindCurrentObject(Page page, ArrayList expectedObject, DataTable table,
													Object TableOrView, string TableName)
		{
			bool bFound = false;
			// comparisons will otherwise fail
			PageStateManager manager = GetPageStateManager(page);
			manager.setLastRow(TableName, -1);
			int iRowCount = manager.GetRowCount(TableName);
			for( int i = 0; i < iRowCount; i++ )
			{
				if( CheckCurrentRow(page, expectedObject, table, TableOrView, i ) )
				{
					manager.setCurrentRow(TableName, i);
					bFound = true;
					break;
				}
			}
			if( !bFound )
			{
/*				if( iRowCount > 0 )
					manager.setCurrentRow(TableName, 0 );
				else */
					manager.setCurrentRow(TableName, -1 );
			}
		}


      private bool IsParentOfChildTable(string tableName, string childTableName)
      {
         DataRelation relation = GetRelation(null, "", childTableName);
         while( relation != null )
         {
			   if( relation.ParentTable.TableName == tableName )
				   return true;
			   relation = GetRelation(null, "", relation.ParentTable.TableName);
		   }
		   return false;
      }
	  // GetConstraints on a child
	  protected void GetConstraintColumnsForChild(string TableName, out DataColumn[] parentConstraintColumns,
													out DataColumn[] childConstraintColumns)
	  {
		 parentConstraintColumns = null;
		 childConstraintColumns = null;
		 DataRelation relation = GetRelation(null, "", TableName);
		 if( relation != null )
		 {
			childConstraintColumns = relation.ChildKeyConstraint.Columns;
			parentConstraintColumns = relation.ParentKeyConstraint.Columns;
		 }
	  }

	  protected void GetConstraintColumnsForParent(string TableName, out DataColumn[] parentConstraintColumns,
													out DataColumn[] childConstraintColumns)
	  {
		 parentConstraintColumns = null;
		 childConstraintColumns = null;
		 DataRelation relation = GetRelation(null, TableName, "");
		 if( relation != null )
		 {
			childConstraintColumns = relation.ChildKeyConstraint.Columns;
			parentConstraintColumns = relation.ParentKeyConstraint.Columns;
		 }
	  }

		// Extract Updated Value for a particular Row/Col/Tablename
	  protected object GetKeyValueFromSession(Page page, string TableName, int iRow, int iCol)
	  {
		 string tableName = "";
		 int row = -1;
		 int col = -1;
		 string oldValue;
		 for( int i = 0;i < page.Session.Count; i++ )
		 {
			if( page.Session.Keys[i].StartsWith( DBWebConst.sDbxDelta + GetPageStateManager(page).GetFullPageName() + TableName + DBWebConst.Splitter)  &&
					page.Session.Keys[i].IndexOf( DBWebConst.sDbxInsert ) < 0 )
			{
				ArrayList parentRows = ClassUtils.GetRowColFromKey(page.Session.Keys[i], GetPageStateManager(page).GetFullPageName(), out tableName, out row, out col, out oldValue);
				if( tableName == TableName && row == iRow && col == iCol )
				{
					if( !IsDetailTable(TableName) || SameParentRow(page, TableName, parentRows ) )
						return page.Session[i];
					break;
				}
			}
		 }
		 return null;
	  }


      protected void addKeyFields(Page page, Object ATableOrView, string TableName,
									DataRow dr, int iRow)

      {
         DataColumn[] parentConstraintCols = null;
         DataColumn[] childConstraintCols = null;
         DataSet ds = null;

         if( ATableOrView is DataTable )
            ds = (ATableOrView as DataTable).DataSet;
         else if( ATableOrView is DataView )
            ds = (ATableOrView as DataView).Table.DataSet;
         GetConstraintColumnsForChild(TableName, out parentConstraintCols, out childConstraintCols);
         if( childConstraintCols != null && parentConstraintCols != null)
         {
            DataRelation relation = GetRelation(page, "", TableName);
            Object ParentTable = getTableOrView(page, relation.ParentTable.TableName, true, false, false);
            for( int j = 0; j < childConstraintCols.Length; j++)
            {
               if(parentConstraintCols[j].ColumnName == childConstraintCols[j].ColumnName)
               {
                  int iParentRow = GetPageStateManager(page).getCurrentRow(relation.ParentTable.TableName);
                  object o = null;
                  if( ParentTable is DataTable )
                  {
                     if( iParentRow < (ParentTable as DataTable).Rows.Count )
                     o = (ParentTable as DataTable).Rows[iParentRow][parentConstraintCols[j].Ordinal];
                  }
                  else if( ParentTable is DataView )
                  {
                     if( iParentRow < (ParentTable as DataView).Count )
                     o = (ParentTable as DataView)[iParentRow].Row[parentConstraintCols[j].Ordinal];
                  }
                  if( o != null )
                     dr[childConstraintCols[j].Ordinal] = o;
               }
            }
         }
         parentConstraintCols = null;
         childConstraintCols = null;
         if( !IsDetailTable(TableName) )
            return;
         // all of the inserted rows are being inserted prior to inserting any
         // updated data for them.  If there are more than 1 inserted rows that
         // have not been updated, this will cause an error when duplicate blank
         // key fields occur. So key values will be retrieved from the Session
         // information and added prior to inserting the next row.
         GetConstraintColumnsForParent(TableName, out parentConstraintCols, out childConstraintCols);
         if( parentConstraintCols != null )
         {
   			for( int j = 0; j < childConstraintCols.Length; j++)
	   		{
               int iCol = parentConstraintCols[j].Ordinal;
               object o = GetKeyValueFromSession(page, TableName, iRow, iCol);
               DataRow dataRow = null;
               if( ATableOrView is DataTable )
                  if( iRow < (ATableOrView as DataTable).Rows.Count )
                     dataRow = (ATableOrView as DataTable).Rows[iRow];
               else if (ATableOrView is DataView)
                  dataRow = dr;
               if( o != null )
                  dataRow[iCol] = o;
            }
         }
      }

      protected DataRelation GetRelation(Page page, string ParentTableName, string ChildTableName)
      {
		   DataSet dataSet;
		   if( page == null )
			   dataSet = DataSetFromDataSource(DataSource);
		   else
			   dataSet = DataSetFromDataSource((this as IDBDataSource).GetDataSource(page));
         if( dataSet == null )
            return null;
		   return GetRelation(page, dataSet, ParentTableName, ChildTableName);
      }

      protected DataRelation GetRelation(Page page, DataSet dataSet, string ParentTableName, string ChildTableName)
      {
         for( int i = 0; i < dataSet.Relations.Count; i++ )
         {
			   if( dataSet.Relations[i].ChildColumns != null )
			   {
				   if( dataSet.Relations[i].ParentTable.TableName == ParentTableName ||
                     dataSet.Relations[i].ChildTable.TableName == ChildTableName)
				      return dataSet.Relations[i];
			   }
		   }
		   return null;
      }

		protected int GetDeleteOrInsertCountFromSession( Page page, string TableName, int iToRow, string KeyType )
		{
			int iCount = 0;
			int iRow, iCol;
			string tableName, oldValue;
			ArrayList parentRows;
			string Key;
			for( int i = 0; i < page.Session.Count; i++ )
			{
				Key = page.Session.Keys[i];
				if( Key.StartsWith(DBWebConst.sDbxDelta + GetPageStateManager(page).GetFullPageName() + TableName + DBWebConst.Splitter) &&
						(KeyType == "" || Key.IndexOf( KeyType) > 0) )
				{
					parentRows = ClassUtils.GetRowColFromKey(Key, GetPageStateManager(page).GetFullPageName(), out tableName, out iRow, out iCol, out oldValue);
					if( (iToRow == -1) || (iRow < iToRow) )
						if( SameParentRow( page, TableName, parentRows ) )
							iCount++;
				}
			}
			return iCount;
		}

		public bool SameParentRow(Page page, string tableName, ArrayList parentRows)
		{
			DataTable table = ParentTableForChildTable(tableName);
			// if tablename is parent, don't worry about parent row position
			if( table == null )
				return true;
			int iTableIndex = IndexOfTable(table.TableName);
			return (int) parentRows[iTableIndex] == GetPageStateManager(page).getCurrentRow(table.TableName);
	   }

		protected void SetSortColumnsReadOnly(Object o)
		{
			if( o is DataView )
			{
				DataView view = (o as DataView);
				for( int i = 0; i < view.Table.Columns.Count; i++ )
					if( IsSortField( view.Table.TableName, view.Table.Columns[i].ColumnName ) )
						view.Table.Columns[i].ReadOnly = true;
            view.AllowNew = false;
			}
      }

		public bool IsSortField(string tableName, string columnName)
		{
			int index = IndexOfTable(tableName);
			string SortColumns = FSortColumns[index].ToString().ToLower();
			bool bIsSortField = SortColumns != "";
			if( bIsSortField )
			{
				int iPos = SortColumns.IndexOf(columnName.ToLower());
				if( iPos > 0 )
				{
					string sBefore = SortColumns.Substring(iPos-1, 1);
					string sAfter = SortColumns.Substring(iPos+columnName.Length, 1);
					bIsSortField = (sBefore == " " || sBefore == ",") &&
										(sAfter == " " || sAfter == ",");
				}
				else
					bIsSortField = false;
			}
			return bIsSortField;
		}

	  public int IndexOfTable(string tableName)
		{
			for( int i = 0; i < RelatedTables.Count; i++ )
				if( RelatedTables[i].ToString() == tableName )
            	return i;
      	return -1;
      }

      public ArrayList RelatedTables
      {
      	get
         {
         	if(FRelatedTables.Count == 0 )
            	GetRelatedTables();
            return FRelatedTables;
         }
      }

      protected void GetRelatedTables()
      {
         ArrayList Temp = new ArrayList();
         FRelatedTables.Clear();
         DataSet dataSet = DataSetFromDataSource(DataSource);
         if( dataSet != null )
         {
            for( int i = 0; i < dataSet.Tables.Count; i++ )
            {
               FRelatedTables.Add(dataSet.Tables[i].TableName);
               if( FDataSource is DataView && (FDataSource as DataView).Table.TableName == dataSet.Tables[i].TableName )
                  FSortColumns.Add("," + (FDataSource as DataView).Sort + ",");
               else
                  FSortColumns.Add("");
            }
         }
      }

      public bool IsMasterTable( string TableName )
      {
         DataRelation relation = GetRelation(null, TableName, "");
         return relation != null;
      }

      protected bool IsDetailTable( string TableName )
      {
         DataRelation relation = GetRelation(null, "", TableName);
         return relation != null;
      }

      private DataTable ParentTableForChildTable(string TableName)
      {
         DataRelation dr = GetRelation(null, "", TableName);
         if( dr == null )
            return null;
         else
            return dr.ParentTable;
      }

		protected string ParentTableNameForChildTable(string TableName)
		{
			DataRelation dr = GetRelation(null, "", TableName);
			if( dr == null )
				return null;
			else
				return dr.ParentTable.TableName;
		}

      public DataColumn[] GetForeignKeys(Page page, string TableName)
	  {
		 DataRelation relation = GetRelation(page, TableName, "");
		 if( relation != null )
			return relation.ParentColumns;
		 return null;
	  }

	  protected void MarkKeyField(Page page, string TableName, String ColumnName)
	  {
			page.Session[ClassUtils.GenKeyForForeignKeyColumn(GetPageStateManager(page).GetFullPageName(), TableName, ColumnName)] = true;
	  }
	  protected void MarkKeyFields(Page page, object ATableOrView)
	  {
		 if( (ATableOrView != null) && GetRowCount(ATableOrView) > 0)
		 {
			DataTable table = GetTableFromObject(ATableOrView);
			if( table.PrimaryKey != null )
			{
				foreach(DataColumn col in table.PrimaryKey)
				{
					col.ReadOnly = false;
					MarkKeyField(page, table.TableName, col.ColumnName);
				}
			}
		 }
	  }
	  protected void SetForeignKeysReadOnly(Page page, object ATableOrView, bool value)
	  {
		 if( (ATableOrView != null) && GetRowCount(ATableOrView) > 0)
		 {
			DataTable table = GetTableFromObject(ATableOrView);
			DataColumn[] foreignKeys = GetForeignKeys(page, table.TableName);
			if( foreignKeys != null )
			{
			   for( int i = 0; i < foreignKeys.Length; i ++ )
			   {
				 table.Columns[foreignKeys[i].Ordinal].ReadOnly = value;
				 if( !ClassUtils.IsDesignTime(page) )
					MarkKeyField(page, table.TableName, table.Columns[foreignKeys[i].Ordinal].ColumnName);
			   }
			}
		 }
	  }

	  protected void CheckForeignKeys(PageStateManager manager, Object ATableOrView)
		{
			if( (FCascadeUpdates == CascadingUpdateOption.noMasterKeyUpdate) && !manager.IsInsertingRow(ATableOrView ))
				SetForeignKeysReadOnly(manager.GetPage(), ATableOrView, true);
			else if( FCascadeUpdates == CascadingUpdateOption.noMasterKeyUpdate )
				SetForeignKeysReadOnly(manager.GetPage(), ATableOrView, false);
			else if( ClassUtils.IsDesignTime(manager.GetPage() ) )
				SetForeignKeysReadOnly(manager.GetPage(), ATableOrView, false);
		}

		protected void CheckForNewUser(Page page)
		{
			if( ClassUtils.IsDesignTime(page) || ClassUtils.IsEmpty(FXMLFileName)
							|| page.User.Identity == null ||	ClassUtils.IsEmpty(page.User.Identity.Name)
							|| !FUseUniqueFileName )
				return;
			Object o = page.Session[DBWebConst.sLastUser];
			if( o == null || Convert.ToString(o) != page.User.Identity.Name )
			{
				PageStateManager manager = GetPageStateManager(page);
				ClearDelta(page, true, false);
				LoadXmlChanges(page);
				page.Session[DBWebConst.sLastUser] = page.User.Identity.Name;
			}
		}

		protected Object getTableOrView(Page page, string TableName,
								bool bLimitChildRows, bool bDontUseCache,
                        bool bSetForeignKeys)
		{
			Object o;
			PageStateManager manager = GetPageStateManager(page);
			if( !bDontUseCache && !ClassUtils.IsDesignTime(page) && manager.GetDatasetUpdated(TableName) )
			{
				o = manager.GetTableOrView(TableName);
				if( o != null )
				{
					if( bSetForeignKeys )
						CheckForeignKeys(manager, o);
               return o;
            }
				else
					manager.SetDatasetUpdated(TableName, false);
			}
			bool bIsDetail = IsDetailTable(TableName);
			o = (this as IDBDataSource).GetDataSource(page);
			if(o == null)
				return o;
			if(o is DataView)
			{
				if( (o as DataView).Table == null )
					return null;
				if( (o as DataView).Table.TableName == TableName)
				{
					if( !ClassUtils.IsDesignTime(page) )
						UpdateDataSet(page, o, TableName, true);
					{
						if( manager.SetTableOrView(TableName, o) )
							manager.SetDatasetUpdated(TableName, true);
					}
               if( bSetForeignKeys )
                  CheckForeignKeys(manager, o);
					if( FSortColumns.Count > 0 )
						SetSortColumnsReadOnly(o);
					return o;
				}
			}
			DataSet dataSet = DataSetFromDataSource(o);
			if( !ClassUtils.IsEmpty(FXMLFileName) )
			{
				if(!FRefreshRequested || dataSet.Tables.Count == 0 )
					LoadDataSetFromXMLFile(page, dataSet.Tables.Count > 0 );
				else
					FDataSetPreLoaded = FAutoUpdateCache && FUseUniqueFileName;
			}
			if( FDataSetPreLoaded )
				CheckForNewUser(page);
			Object table = null;
			for( int i = 0; i < dataSet.Tables.Count; i++ )
			{
				if( dataSet.Tables[i].TableName == TableName)
				{
					if( bIsDetail && bLimitChildRows )
					{
						table = GetChildTable(page, TableName);
					}
					else
						table = dataSet.Tables[i];

					if( !ClassUtils.IsDesignTime(page) &&
						 (bLimitChildRows || !bIsDetail) )
					{
						UpdateDataSet(page, table, TableName, true);
						if( bIsDetail )
						{
							if( manager.getCurrentRow(TableName) < 0 )
                     {
                        if((this as IDBDataSource).GetDisplayRowCount(page, TableName) >= 0)
                           manager.setCurrentRow(TableName, 0);
                     }
						}
					}
   					break;
				}
			}
         if( !ClassUtils.IsDesignTime(page ) )
			{
				if( manager.SetTableOrView(TableName, table) )
					manager.SetDatasetUpdated(TableName, true);
			}
         if( bSetForeignKeys )
            CheckForeignKeys(manager, table);
			return table;
		}

		protected bool HasChild(string TableName)
		{
			return (GetRelation(null, TableName, "") != null);
		}

		protected int GetGrandParentRow(Page page, string tableName)
		{
			if( ClassUtils.IsDesignTime(page) )
				return 0;
			object o = page.Session[GetPageStateManager(page).GetFullPageName() + tableName + DBWebConst.sCurrentRowIndex];
			if( o == null )
				return 0;
			int iRetval = Convert.ToInt32(o);
			if( iRetval == -1 )
				return 0;
			return iRetval;
		}


	  protected void SetKeyFieldsReadOnly(string TableName, Object ATableOrView,
						bool SetChild, bool bReadOnlyValue)
		{
			DataColumn[] parentConstraintCols;
			DataColumn[] childConstraintCols;
			DataTable table = null;
			if( ATableOrView is DataTable )
				table = ATableOrView as DataTable;
			else
				table = (ATableOrView as DataView).Table;
			GetConstraintColumnsForChild(TableName, out parentConstraintCols,
														out childConstraintCols);
			if( parentConstraintCols != null && childConstraintCols != null )
			{
				for( int j = 0; j < childConstraintCols.Length; j++)
					if(parentConstraintCols[j].ColumnName == childConstraintCols[j].ColumnName)
					{
						if( SetChild )
							table.Columns[childConstraintCols[j].Ordinal].ReadOnly = bReadOnlyValue;
						else
							table.Columns[parentConstraintCols[j].Ordinal].ReadOnly = bReadOnlyValue;
					}
			}
		}

		private bool KeyMatch( DataRow row, ArrayList keyValues, DataColumn [] columns )
      {
      	for( int i = 0; i < columns.Length; i++ )
         {
         	string s1 = row[columns[i].ColumnName].ToString();
            string s2 = keyValues[i].ToString();
         	if( s1 != s2 )
            	return false;
         }
         return true;
	  }
      private bool SameRow( DataRow targetRow, DataRow sourceRow, DataColumn [] columns )
      {
         for( int i = 0; i < columns.Length; i++ )
         {
         	string columnName = columns[i].ColumnName;
            if( sourceRow[columnName].ToString() != targetRow[columnName].ToString() )
            	return false;
         }
         return columns.Length > 0;
      }

      protected int GetParentRowForChild(Page page, string TableName)
      {
         if( ClassUtils.IsDesignTime(page) )
            return 0;
         DataTable table = ParentTableForChildTable(TableName);
		   if( table == null )
				return 0;
			return GetPageStateManager(page).GetParentRowForChild(table.TableName);
		}

	  /* function is only called when child table exists.  It returns a
		 DataView of the child table containing only those rows which are
		 controlled by the parent key*/
	  protected Object GetChildTable(Page page, string TableName)
	  {
		 Object ds = (this as IDBDataSource).GetDataSource(page);
		 DataSet dataSet = DataSetFromDataSource(ds);
		 return GetChildTable(page, TableName, dataSet);
	  }

	  protected bool UseXmlChangesFile(Page page)
	  {
		  if( ClassUtils.IsDesignTime(page) || page.User == null ||
			page.User.Identity == null || ClassUtils.IsEmpty(page.User.Identity.Name) )
				return false;
		  if( ClassUtils.IsEmpty(FXMLFileName) || FUseUniqueFileName == false )
			  return false;
        return true;
	  }

	  protected NameValueCollection GetChanges(Page page, string TableName)
	  {
			if( UseXmlChangesFile(page) )
				return DeserializeChanges(page);
			else
				return ClassUtils.ChangesForTable(page, TableName);
	  }

	  protected Object GetChildTable(Page page, string TableName, DataSet dataSet)
	  {
			// first, find parent Table for entire Dataset
			DataRelation parentRelation = null;
			for( int i = 0; i < dataSet.Tables.Count; i++ )
			{
				parentRelation = GetRelation(page, dataSet, dataSet.Tables[i].TableName, "");
				if( (parentRelation != null) &&
					(GetRelation(page, dataSet, "", dataSet.Tables[i].TableName) == null ) )
				{
					break;
				}
			}
		 int iRow;
		 DataRelation relation = parentRelation;
		 DataView o = null;
		 PageStateManager manager = GetPageStateManager(page);
		 // create views for each child table until child view is for TableName argument
		 while( relation != null )
		 {
			DataView view;
			if( o == null )  // first parent view
			{
			   if( FDataSource is DataView && (FDataSource as DataView).Table == relation.ParentTable)
			   {
					view = (FDataSource as DataView);
			   }
			   else
				{
					view = new DataView();
					view.Table = relation.ParentTable;
					if( FDataSource is DataView )
						view.RowFilter = ((this as IDBDataSource).GetDataSource(page) as DataView).RowFilter;
			   }
			}
			else             // a child view
				view = o;
			iRow = GetParentRowForChild(page, relation.ChildTable.TableName);
			if( iRow >= view.Count || iRow < 0 )
			{
				if( iRow >= view.Count ) // && view.Count > 0 )
				{
					if( !ClassUtils.IsDesignTime(page) )
					{
						NameValueCollection changes = GetChanges(page, view.Table.TableName);
						dataSet.EnforceConstraints = false;
						int [] parentRows = SaveParentRows(manager);
						SetForeignKeysReadOnly(page, view, false);
						if( changes != null )
							UpdateTableForInserts(manager, changes, view, false);
						if( (FCascadeUpdates == CascadingUpdateOption.noMasterKeyUpdate) && !manager.IsInsertingRow(view))
							SetForeignKeysReadOnly(page, view, true);
						RestoreParentRows(manager, parentRows);
						try
						{
							dataSet.EnforceConstraints = true;
						}
						catch
						{
							// ignore here
						}
					}
				}
				if( iRow >= view.Count || iRow < 0 )
				{   // return a view of Table TableName with no rows
					DataTable emptyTable = view.Table.DataSet.Tables[TableName];
					DataView emptyView = new DataView();
					emptyView.Table = emptyTable;
					emptyView.RowFilter = "1 = 0";
					return emptyView;
				}
			}
			o = view[iRow].CreateChildView(relation);
			if( relation.ChildTable.TableName == TableName )
			{
				SetKeyFieldsReadOnly(TableName, o, true, true );
				break;
			}
			// get new parent relation
			relation = GetRelation(page, dataSet, relation.ChildTable.TableName, "");
		 }
		 return o;
	  }

	  #region Locate

		protected void SetNavigation(Page page, string tableName, string sKey, string value)
		{
			NameValueCollection nvc = page.Session[GetDataSourceName(page) + DBWebConst.sDBWPostCollection] as NameValueCollection;
			if( nvc != null )
			{
				nvc.Add(tableName + DBWebConst.Splitter + sKey, value);
				page.Session[FDataSourceName + DBWebConst.sDBWPostCollection] = nvc;
			}
		}

      protected string GetNextColumnName(ref string KeyFields)
      {
	      string ColumnName;
         if( KeyFields.Length < 1 )
            return "";
         KeyFields = KeyFields.TrimStart();
         int iEnd = KeyFields.IndexOf(';');
         if( iEnd < 1)
	      {
             ColumnName = KeyFields;
             KeyFields = "";
         }
         else
         {
             ColumnName = KeyFields.Substring(0, iEnd);
             KeyFields = KeyFields.Substring(iEnd+1);
         }
         return ColumnName;
      }

      protected int LocateRow(Object o, ArrayList KeyFields, ArrayList KeyValues, bool CaseInsensitive, bool PartialKey)
      {
         int iRowCount = GetRowCount(o);
         DataRow row;
         DataColumnCollection columns;
         if( o is DataTable )
            columns = (o as DataTable).Columns;
         else
            columns = (o as DataView).Table.Columns;

         for( int iRow = 0; iRow < iRowCount; iRow++ )
         {
            if( o is DataTable )
               row = (o as DataTable).Rows[iRow];
            else
               row = (o as DataView)[iRow].Row;
            if( ClassUtils.IsSameRow(row, columns, KeyFields, KeyValues, CaseInsensitive, PartialKey ) )
               return iRow;
         }
         return -1;
      }

      protected int LocateRow(Object o, string KeyFields, ArrayList KeyValues, bool CaseInsensitive, bool PartialKey)
      {
         ArrayList Columns = new ArrayList();
         while( true )
         {
            string sColumn = GetNextColumnName(ref KeyFields);
            if( sColumn != "" )
               Columns.Add(sColumn);
            else
               break;
         }
         return LocateRow(o, Columns, KeyValues, CaseInsensitive, PartialKey);
      }

      protected int Locate(Page page, string TableName, string KeyFields, ArrayList KeyValues, bool CaseInsensitive, bool PartialKey)
      {
        Object o = getTableOrView(page, TableName, true, false, false);
        return LocateRow(o, KeyFields, KeyValues, CaseInsensitive, PartialKey);
      }
     #endregion Locate

	  #endregion table access methods


		#region UpdateDataSet

      protected void CheckCurrentRowChanged(PageStateManager manager, DataView view, DataTable table, ArrayList rowValues)
      {
         int iNewRow;
         int iCurrentRow = manager.getCurrentRow(table.TableName);
         if( view != null )
         {
            iNewRow = GetRowPosition(view, rowValues, -1, null);
         }
         else
         {
            iNewRow = GetRowPosition(table, rowValues, -1, null);
         }
         if( iNewRow != iCurrentRow )
         {
            manager.setCurrentRow(table.TableName, iNewRow);
            manager.setLastRow(table.TableName, iNewRow);
         }
      }

	 /* after applying changes that rowCount and currentRow are still valid */
	 protected void ResetRowCount(Page page, DataSet dataSet,
						ArrayList currentRows)
	 {
		PageStateManager manager = GetPageStateManager(page);
		ArrayList Tables = new ArrayList();
		OrderTables(Tables, dataSet);
		int iRowCount;
		for( int i = 0; i < Tables.Count; i++ )
		{
			DataTable table = GetTableFromObject(Tables[i]);
			if( IsDetailTable( table.TableName ) )
			{
				DataView child = (GetChildTable(page, table.TableName) as DataView);
				if( child == null )
					manager.setCurrentRow(table.TableName, -1);
				else
				{
					iRowCount = (child as DataView).Count;
					manager.SetRowCount(table.TableName, iRowCount);
					if( iRowCount < 1 )
						manager.ResetCurrentRow(-1, table.TableName, -1);
					else
					{
						int iRow = manager.getCurrentRow(table.TableName);
						object o = page.Session[DBWebConst.sApplyDeletes + manager.GetFullPageName() + table.TableName];
						if( o != null )
							iRow -= Convert.ToInt32(o);
						manager.ResetCurrentRow(iRow, table.TableName, -1);
					}
				}
			}
			else
			{
				bool bCurrentRowReset = false;
				DataView view = null;
				if( (FDataSource is DataView) && table.TableName
						== (FDataSource as DataView).Table.TableName )
				{
					view = (FDataSource as DataView);
					iRowCount = view.Count;
				}
				else
				{
					iRowCount = table.Rows.Count;
				}
				manager.SetRowCount(table.TableName, iRowCount);
				if( manager.getCurrentRow(table.TableName) >= iRowCount )
				{
					manager.setCurrentRow(table.TableName, iRowCount-1);
					manager.setLastRow(table.TableName, iRowCount-1);
					bCurrentRowReset = true;
				}
				if( !bCurrentRowReset && currentRows.Count > 0 )
					CheckCurrentRowChanged(manager, view, table, currentRows[i] as ArrayList);
			}
		}
	 }

	 #region NextKey methods
	  /* retrieve next key=value update for table */
	  protected string NextUpdateNameAndValue(PageStateManager manager, NameValueCollection changes, DataTable table,
									ArrayList KeyRows, int row, out int iCol, out string Value)
	  {
		int iRow;
		iCol = -1;
		string tableName;
		string Key;
		string oldValue;
		ArrayList parentRows;
		Value = null;
		for( int i = changes.Count-1; i >= 0; i-- )
		{
		   Key = changes.Keys[i];
		   if( (Key.IndexOf(DBWebConst.sDbxInsert) < 0) && ( Key.IndexOf(DBWebConst.sDbxDelete) < 0 ) )
		   {
			   parentRows = ClassUtils.GetRowColFromKey(Key, manager.GetFullPageName(), out tableName, out iRow, out iCol, out oldValue);
			   if( row == iRow && tableName == table.TableName )
			   {
				  if( SameParentRows(tableName, KeyRows, parentRows) )
				  {
					 Value = changes[i];
					 return Key;
				  }
			   }
		   }
		}
		return null;
	  }
	 #endregion NextKey methods

		#region Parent Row verification
		protected bool SameParentRows(string tableName, ArrayList sourceRows, ArrayList targetRows)
		{
			string parentTable = ParentTableNameForChildTable(tableName);
			while( parentTable != null )
			{
				int tableIndex = IndexOfTable(parentTable);
				if( Convert.ToInt32(sourceRows[tableIndex]) != Convert.ToInt32(targetRows[tableIndex]) )
					return false;
				parentTable = ParentTableNameForChildTable(parentTable);
			}
			return true;
		}

		protected bool SameParentRows(Page page, string tableName, ArrayList parentRows)
		{
			string parentTable = tableName;
			while( parentTable != null )
			{
				if( !SameParentRow(page, parentTable, parentRows) )
					return false;
				parentTable = ParentTableNameForChildTable(parentTable);
			}
			return true;
	  }
	  /* verify that child row changed is the child of the current parent */
	  protected bool IsCorrectChild(PageStateManager manager, string tableName, ArrayList KeyRows)
	  {
		 int iParentRow;
		 int iThisParentRow;
		 /* check each table in dataset and make sure that either:
				1.  its CurrentRow is correct as a parent of this table, or
				2.  its not related to this this table,
				3.  it is this table */
		 for( int j = 0; j < RelatedTables.Count; j++ )
		 {
			if( RelatedTables[j].ToString() == tableName )
				continue;
			iParentRow = manager.getCurrentRow(RelatedTables[j].ToString() );
			iThisParentRow = Convert.ToInt32(KeyRows[j]);
			if( iParentRow != iThisParentRow )
			{
				if( IsParentOfChildTable(RelatedTables[j].ToString(), tableName ) )
				{
					return false;
				}
			}
		 }
		 return true;
	  }

	  /* all parent's CurrentRow need be the correct row for the sought child */
	  protected void SetParentRows(PageStateManager manager, ArrayList KeyRows, DataTable table)
	  {
		string parentTable = ParentTableNameForChildTable(table.TableName);
		while( parentTable != null )
		{
			int tableIndex = IndexOfTable(parentTable);
			manager.setCurrentRow(parentTable, Convert.ToInt32(KeyRows[tableIndex]));
			parentTable = ParentTableNameForChildTable(parentTable);
		}
	  }

	 #endregion Parent Row verification

	 #region Insertion logic

	 protected void addChildKeys(PageStateManager manager, DataTable table,
					ArrayList KeyRows, DataRow dr, int iRow)
	  {
		 DataColumn[] parentConstraintCols = null;
		 DataColumn[] childConstraintCols = null;
		 DataSet ds = null;

		 ds = table.DataSet;
		 GetConstraintColumnsForChild(table.TableName, out parentConstraintCols, out childConstraintCols);
		 if( childConstraintCols != null && parentConstraintCols != null)
		 {
			DataRelation relation = GetRelation(manager.GetPage(), ds, "", table.TableName);
			int [] parentRows = SaveParentRows(manager);
			SetParentRows(manager, KeyRows, table);
			try
			{
				Object ParentTable = getTableOrView(manager.GetPage(), relation.ParentTable.TableName, true, false, false);
				for( int j = 0; j < childConstraintCols.Length; j++)
				{
					if(parentConstraintCols[j].ColumnName == childConstraintCols[j].ColumnName)
					{
						int iParentRow = manager.getCurrentRow(relation.ParentTable.TableName);
						object o = null;
						/* if parent row has been deleted then current child row is about to be deleted,
							so there's no need to add key field */
						if( ParentTable is DataTable )
						{
							if( iParentRow < (ParentTable as DataTable).Rows.Count )
								o = (ParentTable as DataTable).Rows[iParentRow][parentConstraintCols[j].Ordinal];
						}
						else if( ParentTable is DataView )
						{
							if( iParentRow < (ParentTable as DataView).Count )
								o = (ParentTable as DataView)[iParentRow].Row[parentConstraintCols[j].Ordinal];
						}
						if( o != null )
							dr[childConstraintCols[j].Ordinal] = o;
					}
				}
			}
			finally
			{
				RestoreParentRows(manager, parentRows);
			}
		 }
	  }

	  protected void AddValuesForInsertedRow(PageStateManager manager,
								  NameValueCollection changes,
								  ArrayList KeyRows, DataTable table,
								  DataRow dr, int row)
	  {
		string Value = null;
		int iCol;
		ArrayList ColumnsSet = new ArrayList();
		string Key = NextUpdateNameAndValue(manager, changes, table, KeyRows, row,
							out iCol, out Value);
		while( Key != null )
		{
			if( !ClassUtils.CheckValuesSet( Key, ColumnsSet ) )
			{
				ColumnsSet.Add(Key);
				SetValue(table.Columns[iCol], dr, Value);
			}
			changes.Remove(Key);
			Key = NextUpdateNameAndValue(manager, changes, table, KeyRows, row,
									out iCol, out Value);
		}
	  }

	  protected void UpdateTableForInserts(PageStateManager manager, NameValueCollection changes, Object ATableOrView,
						bool AcceptChanges)
	  {
		DataTable table = GetTableFromObject(ATableOrView);
		int iRow;
		int iCol;
		string tableName;
		string oldValue;
		string InsertKey = ClassUtils.NextInsertKey(manager.GetFullPageName(), changes, table.TableName);
		/* get all changes from session */
		/* will be updating key fields with parent key values, so ....*/
		SetKeyFieldsReadOnly(table.TableName, table, true, false);
		while( InsertKey != null )
		{
			ArrayList KeyRows = ClassUtils.GetRowColFromKey(InsertKey, manager.GetFullPageName(), out tableName, out iRow, out iCol, out oldValue);
			if( tableName == table.TableName && (!AcceptChanges ||
				 !IsDetailTable(table.TableName) || SameParentRows(manager.GetPage(), tableName, KeyRows) ) )
			{
				DataRow dr = null;
				dr = table.NewRow();
				table.Rows.Add(dr);
				if( IsDetailTable(table.TableName ) )
					addChildKeys(manager, table, KeyRows, dr, iRow);
				else
					addKeyFields(manager.GetPage(), table, table.TableName, dr, iRow);
				AddValuesForInsertedRow(manager, changes, KeyRows, table, dr, iRow);
			}
			changes.Remove(InsertKey);
			InsertKey = ClassUtils.NextInsertKey(manager.GetFullPageName(), changes, table.TableName);
		}
		SetKeyFieldsReadOnly(table.TableName, table, true, true);
		return;
	  }
	  #endregion Insert logic

      #region Update logic

      private void UpdateChildRows(PageStateManager manager, DataRelation relation, int iCol, string parentValue, string Value)
      {
         relation.ChildTable.Columns[iCol].ReadOnly = false;
         try
         {
            for( int i = 0; i < relation.ParentColumns.Length; i++ )
            {
               if( relation.ParentColumns[i].Ordinal == iCol )
               {
                  string RowFilter, NewFilter;
                  RowFilter = GetFilterForColumn(relation.ChildColumns[i], parentValue);
                  NewFilter = GetFilterForColumn(relation.ChildColumns[i], Value);
                  relation.ChildTable.DefaultView.RowFilter = RowFilter;
                  while( relation.ChildTable.DefaultView.Count > 0 )
                     relation.ChildTable.DefaultView[0].Row[relation.ChildColumns[i].Ordinal] = Value;
						relation.ChildTable.DefaultView.RowFilter = NewFilter;
						if( manager.SetTableOrView(relation.ChildTable.TableName, relation.ChildTable.DefaultView) )
							manager.SetDatasetUpdated(relation.ChildTable.TableName, true);
						break;
               }
            }
         }
         finally
         {
            relation.ChildTable.Columns[iCol].ReadOnly = true;
         }
      }

      private bool UpdateChildKeys(PageStateManager manager, Object ParentTableOrView,
                     int iRow, int iCol, string Value)
      {
         bool Updated = false;
         DataTable table = GetTableFromObject(ParentTableOrView);
         DataRelation relation = GetRelation(manager.GetPage(), table.TableName, "" );
         if( relation != null )
         {
            relation.DataSet.EnforceConstraints = false;
            int iCurrentRow = manager.getCurrentRow(table.TableName);
            try
            {
               manager.setCurrentRow(table.TableName, iRow);
               DataRow parentRow = GetRow(ParentTableOrView, iRow);
               string oldValue = Convert.ToString(parentRow[iCol]);
               parentRow[iCol] = Value;
               UpdateChildRows(manager, relation, iCol, oldValue, Value);
            }
            finally
            {
               manager.setCurrentRow(table.TableName, iCurrentRow);
            }
         }
         return Updated;
      }

      private bool IsForeignKeyColumn(Page page, DataTable table, int iCol)
      {
         DataColumn[] foreignKeys = GetForeignKeys(page, table.TableName);
         if( foreignKeys != null )
         {
            for( int i = 0; i < foreignKeys.Length; i++ )
               if( foreignKeys[i].Ordinal == iCol )
                  return true;
         }
         return false;
		}

		private void UpdateTableRow(PageStateManager manager,
						object ATableOrView, string Key, string Value,
						bool AcceptChanges)
		{
			DataTable table = GetTableFromObject(ATableOrView);
			int iRow, iCol;
			ArrayList parentRows;
			string tableName, oldValue;
			parentRows = ClassUtils.GetRowColFromKey(Key, manager.GetFullPageName(), out tableName, out iRow, out iCol, out oldValue);
			table.Columns[iCol].ReadOnly = false;
			if( FCascadeUpdates != CascadingUpdateOption.noMasterKeyUpdate )
			{
				if( FCascadeUpdates == CascadingUpdateOption.serverNoForeignKey
						|| AcceptChanges || (!ClassUtils.IsEmpty(FXMLFileName) && FAutoUpdateCache ) )
				{
					if( IsForeignKeyColumn(manager.GetPage(), table, iCol ) )
						UpdateChildKeys( manager, ATableOrView, iRow, iCol, Value );
				}
			}
			if( IsDetailTable(table.TableName) )
			{
				if( (this as IDBPageStateManager).UsesHardDeletes(manager.GetPage(), table.TableName) )
					iRow -= manager.GetDeleteCount(table.TableName, iRow);
				SetParentRows(manager, parentRows, table);
				DataView childTable = GetChildTable(manager.GetPage(), table.TableName, table.DataSet) as DataView;
				if( childTable.Count > iRow )
					SetValue(table.Columns[iCol], childTable[iRow].Row, Value);
			}
			else
			{
				if( ATableOrView is DataView )
					SetValue(table.Columns[iCol], (ATableOrView as DataView)[iRow].Row, Value);
				else
					SetValue(table.Columns[iCol], table.Rows[iRow], Value);
			}
		}

	  /* each time a change from changes is put into table it is removed from changes */
	  private void UpdateTableForUpdates(PageStateManager manager,
							NameValueCollection changes,
							Object ATableOrView, bool AcceptChanges)
	  {
		DataTable table = GetTableFromObject(ATableOrView);
		string Key = ClassUtils.NextUpdateKey(manager.GetFullPageName(), changes, table.TableName);
		ArrayList ColumnsSet = new ArrayList();
		while(Key != null )
		{
			if( !ClassUtils.CheckValuesSet(Key, ColumnsSet) )
			{
				ColumnsSet.Add(Key);
				UpdateTableRow(manager, ATableOrView, Key, changes[Key], AcceptChanges);
			}
			changes.Remove(Key);
			Key = ClassUtils.NextUpdateKey(manager.GetFullPageName(), changes, table.TableName);
		}
	  }
	  #endregion Update logic

	  #region Delete logic

	  private int AdjustRow(PageStateManager manager, int CurrentRow, ArrayList parentRows, ArrayList rowsDeleted)
	  {
		string tableName, oldValue;
		int ReturnRow = CurrentRow;
		int iRow, iCol;
		ArrayList pRows;
		for( int i = 0; i < rowsDeleted.Count; i++ )
		{
			string Key = rowsDeleted[i].ToString();
			pRows = ClassUtils.GetRowColFromKey(Key, manager.GetFullPageName(), out tableName, out iRow, out iCol, out oldValue);
			/* if a deleted row precedes the current row, adjust */
			if( iRow < CurrentRow )
				if( SameParentRows(tableName, pRows, parentRows) )
					ReturnRow--;
		}
		return ReturnRow;
	   }

      private void DeleteAllRows(PageStateManager manager, string parentTable, string tableName, int iRow)
      {
         int iCurrentRow = manager.getCurrentRow(parentTable);
         try
         {
            manager.setCurrentRow(parentTable, iRow);
            DataView view = getTableOrView(manager.GetPage(), tableName, true, false, false) as DataView;
            for( int i = 0; i < view.Count; i++ )
               view.Delete(i);
         }
         finally
         {
            manager.setCurrentRow(parentTable, iCurrentRow);
         }
      }


      private void DeleteTableRow(PageStateManager manager,
						Object ATableOrView, string Key, NameValueCollection changes,
						ArrayList rowsDeleted, bool AcceptChanges)
      {
         DataTable table = GetTableFromObject(ATableOrView);
         int iRow, iCol;
         int iRowCount = GetRowCount(ATableOrView);
         string tableName, oldValue;
         ArrayList parentRows = ClassUtils.GetRowColFromKey(Key, manager.GetFullPageName(), out tableName, out iRow, out iCol, out oldValue);
         if( AcceptChanges || (this as IDBPageStateManager).UsesHardDeletes(manager.GetPage(), table.TableName) )
            iRow = AdjustRow(manager, iRow, parentRows, rowsDeleted);
         // if Apply Event is to be called, and Parent Row has been deleted,
         // then delete children rows.
         if( (FCascadeDeletes == CascadingDeleteOption.serverNoForeignKey) && !AcceptChanges )
         {
            DataRelation relation = GetRelation(manager.GetPage(), table.TableName, "" );
            string parentTable = tableName;
            while( relation != null )
            {
               DeleteAllRows(manager, parentTable, relation.ChildTable.TableName, iRow);
               parentTable = relation.ChildTable.TableName;  
               relation = GetRelation(manager.GetPage(), relation.ChildTable.TableName, "" );
            }
         }
         if( IsDetailTable(table.TableName) )
         {
            SetParentRows(manager, parentRows, table);
            DataView childView = GetChildTable(manager.GetPage(), table.TableName, table.DataSet) as DataView;
            if( childView.Count > iRow )
               childView[iRow].Row.Delete();
         }
         else
         {
            if( ATableOrView is DataView )
            {
               if( AcceptChanges )
                  (ATableOrView as DataView)[iRow].Row.AcceptChanges();
                  (ATableOrView as DataView)[iRow].Row.Delete();
               if( AcceptChanges && iRow < (ATableOrView as DataView).Count )
                  (ATableOrView as DataView)[iRow].Row.AcceptChanges();
            }
            else
            {
				// if row is inserted, we need to AcceptChanges
				// prior to
               if( AcceptChanges )
                  table.Rows[iRow].AcceptChanges();
               table.Rows[iRow].Delete();
               if( AcceptChanges && table.Rows.Count > iRow )
                  table.Rows[iRow].AcceptChanges();
            }
         }
         if( iRowCount > GetRowCount(ATableOrView) )
            manager.GetPage().Session[manager.GetFullPageName() + DBWebConst.sHardDeletes + table.TableName] = true;
      }

	  /* each time a change from changes is put into table it is removed from changes */
	  private void UpdateTableForDeletes(PageStateManager manager,
							NameValueCollection changes, Object ATableOrView,
							bool AcceptChanges)
	  {
		DataTable table = GetTableFromObject(ATableOrView);
		ArrayList rowsDeleted = new ArrayList();
		string Key = ClassUtils.NextDeleteKey(manager.GetFullPageName(), changes, table.TableName);
		int iDeleted = 0;
		while(Key != null )
		{
			DeleteTableRow(manager, ATableOrView, Key, changes, rowsDeleted, AcceptChanges);
			iDeleted++;
			changes.Remove(Key);
			rowsDeleted.Add(Key);
			Key = ClassUtils.NextDeleteKey(manager.GetFullPageName(), changes, table.TableName);
		}
		manager.GetPage().Session[DBWebConst.sApplyDeletes+table.TableName] = iDeleted;
	  }
	  #endregion Delete logic

      private int [] SaveParentRows(PageStateManager manager)
      {
         int [] currentRows = manager.CurrentRow;
         int [] parentRows = new int[currentRows.Length];
         for( int i = 0; i < parentRows.Length; i++ )
				parentRows[i] = currentRows[i];
         return parentRows;
		}

      private void RestoreParentRows(PageStateManager manager, int[] parentRows)
      {
         for( int i = 0; i < parentRows.Length; i++ )
         {
            manager.setCurrentRow(RelatedTables[i].ToString(), parentRows[i]);
//          manager.setLastRow(RelatedTables[i].ToString(), -1);
			}
		}

		protected void RemoveLastChange(Page page)
		{
			if( ClassUtils.IsEmpty(FXMLFileName) )
				return;
			NameValueCollection changes = DeserializeChanges(page);
         if( changes != null )
            if( changes.Count > 0 )
               changes.Remove(changes.GetKey(changes.Count -1 ) );
      }

		private void LoadXmlChanges(Page page)
		{
			ClearDelta(page, false, false);
			NameValueCollection changes = DeserializeChanges(page);
			if( changes != null )
				for( int i = 0; i < changes.Count; i++ )
					page.Session.Add(changes.GetKey(i), changes[i]);
      }

		private NameValueCollection DeserializeChanges(Page page)
      {
         NameValueCollection nvc = null;
         string fileName = UserBasedFileName(page, false);
			if( ClassUtils.IsEmpty(fileName) )
            return nvc;
         string changesXmlFile = ClassUtils.GetChangesFileName(fileName);
         if(!File.Exists(changesXmlFile) )
            return nvc;
         FileStream fs = new FileStream(changesXmlFile, FileMode.Open);
         try
         {
				SoapFormatter formatter = new SoapFormatter();
				nvc = (NameValueCollection) formatter.Deserialize(fs);
         }
         finally
         {
            fs.Close();
         }
         return nvc;
      }

		private void SerializeChanges(Page page, NameValueCollection changes)
		{
			// bug in XmlSerializer with NameValueCollection:
			// need to use SoapFormatter;
			FXMLLoaded = false;
			GetPageStateManager(page).ClearUpdated();
			string fileName = UserBasedFileName(page, false);
			string changesXmlFile = ClassUtils.GetChangesFileName(fileName);
			if(File.Exists(changesXmlFile) )
				File.Delete(changesXmlFile);
			if(changes.Count == 0 )
				return;

			FileStream fs = new FileStream(changesXmlFile, FileMode.Create);
			SoapFormatter formatter = new SoapFormatter();
			try
			{
				formatter.Serialize(fs, changes);
			}
			finally
			{
				fs.Close();
			}
		}

		protected void UpdateTables(Page page, ArrayList tables, NameValueCollection changes,
											 bool AcceptChanges)
		{
			NameValueCollection saveChanges = null;
			if( FDataSetPreLoaded )
			{
				saveChanges = new NameValueCollection(changes);
			}
			PageStateManager manager = GetPageStateManager(page);
			int [] parentRows = SaveParentRows(manager);
			try
			{
				for( int i = 0; i < tables.Count; i++)
				{
					SetForeignKeysReadOnly(page, tables[i], false);
					MarkKeyFields(page, tables[i]);
					UpdateTableForInserts(manager, changes, tables[i], AcceptChanges);
					UpdateTableForUpdates(manager, changes, tables[i], AcceptChanges);
					UpdateTableForDeletes(manager, changes, tables[i], AcceptChanges);
				}
				if( !ClassUtils.IsEmpty(FXMLFileName) && FAutoUpdateCache )
				{
					UpdateUserCacheFile(page, tables[0], saveChanges);
				}
			}
			finally
			{
				RestoreParentRows(manager, parentRows);
			}
		}

		private void UpdateUserCacheFile(Page page, Object table, NameValueCollection saveChanges)
		{
			if( !FDataSetPreLoaded )
			{
				string uniqueXMLFile = UserBasedFileName(page, false);
				DataSet ds = null;
				ds = DataSetFromDataSource(table);
				ds.AcceptChanges();
				ds.WriteXml(uniqueXMLFile);
                                //Fix for 213540
				if (FAutoUpdateCache && !ClassUtils.IsDesignTime(page))
                                {
                                  DataTable tab = GetTableFromObject(table);
                                  if (tab != null)
                                  {
                     		    PageStateManager manager = GetPageStateManager(page);
                                    manager.SetRowCount(tab.TableName, tab.Rows.Count);
                                  }
                                }

				ClearSessionState(page, false, false);
				if( !ClassUtils.IsDesignTime(page) && !FAutoRefresh )
					page.Session[GetDataSourceName(page) + DBWebConst.sDataSource] = ds;
			}
		}

	  /* load relevant session information for table as NameValueCollection,
		  then pass them on to UpdateTables*/
		protected void UpdateTables(Page page, ArrayList detailTables)
		{
			NameValueCollection changes = ClassUtils.ChangesForTable(page, "");
			if( changes.Count > 0 )
			{
				UpdateTables(page, detailTables, changes, false);
			}
		}

	  /* Order the detail in such a way that parents precede children;
		 this is necessary so that inserted parent rows preceded inserted
		 detail rows */
		private void OrderTables(ArrayList tableList, DataSet ds)
		{
			ArrayList tables = new ArrayList();
			// add non-detail tables, store off detail tables
			for( int i = 0; i < ds.Tables.Count; i++ )
			{
				if( IsDetailTable(ds.Tables[i].TableName ) )
					tables.Add(ds.Tables[i].TableName);
				else
				{
					if( (FDataSource is DataView) &&
							(ds.Tables[i].TableName == (FDataSource as DataView).Table.TableName) )
						tableList.Add(FDataSource);
					else
						tableList.Add(ds.Tables[i]);
				}
			}
			int index = 0;
			while( tables.Count > 0 )
			{
				// if table's parent is not in the list, add it to list first
				if( tables.IndexOf(ParentTableNameForChildTable(Convert.ToString(tables[index]))) < 0 )
				{
					tableList.Add(ds.Tables[tables[index].ToString()]);
					tables.Remove(tables[index].ToString());
				}
				else
				{ // if table's parent is in the list,
					//  wait till its parent is added to details
					index++;
					if( index >= tables.Count )
						index = 0;
				}
			}
	  }

		public void UpdateDataSet(Page page, Object ATableOrView, string TableName,
						bool bRequiresSameParentRow)
		{
			if( ATableOrView == null || !(this as IDBDataSource).HasDelta( page, TableName ) )
				return;
			// if dataset is cached then there is no need to update.  Update
			// is only required after refresh and before ApplyUpdates
			// Detail tables are temporary tables that need to be udpated
			// each time they are retrieved
			PageStateManager manager = GetPageStateManager(page);
			if( manager.GetDatasetUpdated(TableName) && !IsDetailTable(TableName) )
				return;
			if( !ClassUtils.IsDesignTime(page) )
			{
				try
				{
					NameValueCollection changes = GetChanges(page, TableName);
					if( changes != null && changes.Count > 0 )
					{
						DataSet dataSet = GetTableFromObject(ATableOrView).DataSet;
						dataSet.EnforceConstraints = false;
						ArrayList tables = new ArrayList();
						tables.Add(ATableOrView);
						UpdateTables(page, tables, changes, true);
						if( !manager.IsInsertingRow( ) && GetRowCount(ATableOrView) > 0)
						{
							try
							{
								dataSet.EnforceConstraints = true;
							}
							catch (Exception exp)
							{
								page.Session[manager.GetFullPageName() + TableName + DBWebConst.sInsertingRow] = true;
								manager.clientAction = ClientAction.ecaNone;
										 manager.setCurrentRow(TableName, manager.getLastRow(TableName) );
								manager.HandleException(exp, "", false);
							}
						}
					}
				}
				catch (Exception exp)
				{
					manager.clientAction = ClientAction.ecaNone;
					manager.HandleException(exp, "", false);
				}
			}
		}


#endregion UpdateDataSet


		#region DBWebControlCollection events

		[LocalizableCategoryAttribute("OnApplyChangesRequest")]
		[LocalizableDescriptionAttribute("OnApplyChangesRequest")]
		public event WebControlEvent OnApplyChangesRequest;
		[LocalizableCategoryAttribute("OnAutoApplyRequest")]
		[LocalizableDescriptionAttribute("OnAutoApplyRequest")]
		public event WebControlEvent OnAutoApplyRequest;
		[LocalizableCategoryAttribute("OnGetPostCollection")]
		[LocalizableDescriptionAttribute("OnGetPostCollection")]
		public event PostCollectionEvent OnGetPostCollection;
		[LocalizableCategoryAttribute("OnAfterSetChanges")]
		[LocalizableDescriptionAttribute("OnAfterSetChanges")]
		public event WebControlEvent OnAfterSetChanges;
		[LocalizableCategoryAttribute("OnRefreshRequest")]
		[LocalizableDescriptionAttribute("OnRefreshRequest")]
		public event WebControlEvent OnRefreshRequest;
		[LocalizableCategoryAttribute("OnScroll")]
		[LocalizableDescriptionAttribute("OnScroll")]
		public event OnScrollEvent OnScroll;
		[LocalizableCategoryAttribute("OnError")]
		[LocalizableDescriptionAttribute("OnError")]
		public event OnErrorEvent OnError;

		protected virtual void DoOnScroll(string TableName, int currentRow, int priorRow)
		{
			if(OnScroll != null)
			{
				OnScrollEventArgs e = new OnScrollEventArgs(TableName, currentRow, priorRow);
				OnScroll(this, e);
			}
		}

		protected virtual void DoOnError(Page page)
		{
			PageStateManager manager = GetPageStateManager(page);
			if(OnError != null)
			{
				DataSet ds = DataSetFromDataSource((this as IDBDataSource).GetDataSource(page));
				OnErrorEventArgs e = new OnErrorEventArgs(ds, manager.Errors, manager.Warnings);
				OnError(this, e);
			}
			manager.Errors.Clear();
			manager.Warnings.Clear();
		}

		protected void AdjustRowCountForDeletedRow(Page page, string sKey)
		{
			string tableName;
			int iRow, iCol;
			string sOldValue;
			PageStateManager manager = GetPageStateManager(page);
			ClassUtils.GetRowColFromKey(sKey, GetPageStateManager(page).GetFullPageName(), out tableName, out iRow, out iCol, out sOldValue);
			int iCurrentRow = manager.getCurrentRow(tableName);
			if( iRow <= iCurrentRow )
				manager.ResetCurrentRow( iCurrentRow -1, tableName, -1);
		}

		public void ClearSessionChanges(Page page)
		{
			ClearSessionState(page, true, true);
		}

		protected void ClearDelta(Page page, bool bResetRow, bool bCancelChanges)
		{
			for( int i = page.Session.Count -1; i >= 0; i-- )
			{
				if( page.Session.Keys[i].StartsWith(DBWebConst.sDbxDelta + GetPageStateManager(page).GetFullPageName()) )
				{
					if( page.Session.Keys[i].IndexOf(DBWebConst.sDbxDelete) > 0 )
						AdjustRowCountForDeletedRow(page, page.Session.Keys[i]);
					page.Session.Remove(page.Session.Keys[i]);
				}
			}
			if( bCancelChanges )
				page.Session[DBWebConst.sCancelAll + GetPageStateManager(page).GetFullPageName() ] = "true";
			if( bResetRow )
			{
				PageStateManager manager = GetPageStateManager(page);
				for( int i = 0; i < RelatedTables.Count; i++ )
					manager.setCurrentRow(manager.GetFullPageName() + RelatedTables[i].ToString(), 0);
			}
		}

		public void ClearSessionState(Page page, bool bResetRowPosition, bool bCancelChanges)
		{
			ClearDelta(page, false, bCancelChanges);
			if( ! FAutoRefresh )
				page.Session[GetDataSourceName(page) + DBWebConst.sDataSource] = FDataSource;
			int iRowCount;
			PageStateManager manager = GetPageStateManager(page);
			for( int i = 0; i < RelatedTables.Count; i++ )
			{
				manager.RemoveDeletedRows(RelatedTables[i].ToString());
				manager.RemoveInsertedRows(RelatedTables[i].ToString());
				if( bResetRowPosition )
				{
					manager.SetDatasetUpdated(RelatedTables[i].ToString(), false);
					Object o = getTableOrView(page, RelatedTables[i].ToString(), true, false, false);
					if( o is DataTable )
						iRowCount = (o as DataTable).Rows.Count;
					else if( o is DataView )
						iRowCount = (o as DataView).Count;
					else
						iRowCount = -1;
					manager.SetRowCount(RelatedTables[i].ToString(), iRowCount);
					if( iRowCount > 0 )
						manager.ResetCurrentRow(0, RelatedTables[i].ToString(), -1);
					else
						manager.ResetCurrentRow(-1, RelatedTables[i].ToString(), -1);
				}
				page.Session.Remove(GetDataSourceName(page) + RelatedTables[i].ToString() + DBWebConst.sDBWPostCollection);
			}
		}


		protected void RefreshDataSetFromSession(Page page)
		{
			DataSet dataSet = DataSetFromDataSource(FDataSource);
			RefreshDataSetFromSession(page, dataSet);
		}

		protected void RefreshDataSetFromSession(Page page, DataSet dataSet)
		{
			ArrayList Tables = new ArrayList();
			OrderTables(Tables, dataSet);
			UpdateTables(page, Tables);
		}

		protected bool HardUpdate(Page page, ArrayList currentRows)
		{
			PageStateManager manager = GetPageStateManager(page);
			bool NeedsUpdate = false;
			DataSet dataSet = DataSetFromDataSource(FDataSource);
			dataSet.EnforceConstraints = false;
				// first, do tables that are not detail tables, so the
				// details have all parent rows prior to attempting a change
			for( int i = 0; i < dataSet.Tables.Count; i++ )
			{
				if( (this as IDBDataSource).HasDelta(page, dataSet.Tables[i].TableName ) )
					NeedsUpdate = true;
			}
			if( NeedsUpdate )
			{
				RefreshDataSetFromSession(page, dataSet);
				dataSet.EnforceConstraints = true;
				currentRows.Clear();
				for( int i = 0; i < dataSet.Tables.Count; i++ )
				{
					if( IsDetailTable(dataSet.Tables[i].TableName) )
						currentRows.Add(null);
					else
					{
						Object table = getTableOrView(page, dataSet.Tables[i].TableName, true, false, false);
						currentRows.Add(GetRowValues(table, manager.getCurrentRow(dataSet.Tables[i].TableName)));
					}
				}
			}
			return NeedsUpdate;
		}

		protected virtual bool DoOnGetPostCollection(NameValueCollection postCollection)
		{
			if( OnGetPostCollection != null )
			{
				PostCollectionEventArgs e = new PostCollectionEventArgs(postCollection);
				bool StopChanges;
				OnGetPostCollection(this, e, out StopChanges);
				return StopChanges;
			}
			return false;
		}
		protected virtual void DoOnAfterSetChanges()
		{
			DataSet dataSet = DataSetFromDataSource(FDataSource);
			if( OnAfterSetChanges != null )
			{
				WebControlEventArgs e = new WebControlEventArgs(dataSet);
				OnAfterSetChanges(this, e);
			}
		}
		protected virtual void DoOnApplyChanges(Page page, WebControlEvent ApplyEvent)
		{
			DataSet dataSet = DataSetFromDataSource(FDataSource);
			if( ApplyEvent!= null && dataSet != null )
			{
				ArrayList currentRows = new ArrayList();
				try
				{
					if( HardUpdate(page, currentRows) )
					{
						WebControlEventArgs e = new WebControlEventArgs(dataSet);
						ApplyEvent(this, e);
						dataSet = DataSetFromDataSource(FDataSource);
						if( dataSet.GetChanges() == null )
						{
							ClearSessionState(page, false, true);
							ResetRowCount(page, dataSet, currentRows);
							// TODO: what if user wants to clear out changes
							// manually for changing a DataView.RowFilter
							if( FDataSetPreLoaded )
								(this as IDBDataSource).DeleteUserXmlFile(page);
							if( !ClassUtils.IsDesignTime(page) && !FAutoRefresh )
							{
								page.Session[GetDataSourceName(page) + DBWebConst.sDataSource] = FDataSource;
							}
						}
					}
				}
				catch( Exception ex )
				{
					PageStateManager manager = GetPageStateManager(page);
					manager.HandleException(ex, "", true);
					for( int i = 0; i < dataSet.Tables.Count; i++ )
						manager.SetDatasetUpdated( dataSet.Tables[i].TableName, false );
					ResetRowCount(page, dataSet, currentRows);
				}
			}
		}

		protected virtual void DoOnRefresh(Page page)
		{
			if( OnRefreshRequest != null && FDataSource != null )
			{
				DataSet dataSet = DataSetFromDataSource(FDataSource);
				WebControlEventArgs e = new WebControlEventArgs(dataSet);
				OnRefreshRequest(this, e);
			}
			if( !ClassUtils.IsDesignTime(page) )
			{
				if( FDataSetPreLoaded )
				{
					(this as IDBDataSource).DeleteUserXmlFile(page);
					FXMLLoaded = false;
					GetPageStateManager(page).ClearUpdated();
				}
				if( !FAutoRefresh )
					page.Session[GetDataSourceName(page) + DBWebConst.sDataSource] = FDataSource;
			}
		}

	  #endregion
   }

   #endregion

}
